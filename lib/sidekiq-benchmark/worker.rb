# frozen_string_literal: true

module Sidekiq
  module Benchmark
    module Worker
      def benchmark(options = {})
        @benchmark ||= Benchmark.new self, benchmark_redis_type_key, options

        if block_given?
          yield @benchmark
          @benchmark.finish
        end

        @benchmark
      end

      def benchmark_redis_type_key
        @benchmark_redis_type_key ||= self.class.name.gsub('::', '_').downcase
      end

      class Benchmark
        attr_reader :metrics, :start_time, :finish_time, :redis_keys

        def initialize(worker, redis_key, options)
          @metrics = {}
          @worker = worker
          @options = options
          @start_time = Time.now

          @redis_keys =
            %i[total stats].reduce({}) do |m, e|
              m[e] = "#{REDIS_NAMESPACE}:#{redis_key}:#{e}"
              m
            end

          set_redis_key redis_key
        end

        def finish
          @finish_time = Time.now
          self[:job_time] = finish_time - start_time
          save
        end

        def measure(name)
          t0  = Time.now
          ret = yield
          t1  = Time.now

          self[name] ||= 0.0
          self[name] += t1 - t0

          ret
        end
        alias_method :bm, :measure

        def call(name, *args)
          measure(name) { @worker.send(name, *args) }
        end

        def []=(name, value)
          @metrics[name] = value.to_f
        end

        def [](name)
          @metrics[name]
        end

        def set_redis_key(key)
          Sidekiq.redis do |conn|
            conn.sadd Sidekiq::Benchmark::TYPES_KEY, key
            conn.expire Sidekiq::Benchmark::TYPES_KEY, REDIS_KEYS_TTL
          end
        end

        def save
          job_time_key = @metrics[:job_time].round(1)

          Sidekiq.redis do |conn|
            conn.multi do
              @metrics.each do |key, value|
                conn.hincrbyfloat redis_keys[:total], key, value
              end

              conn.hincrby redis_keys[:stats], job_time_key, 1

              conn.hsetnx redis_keys[:total], "start_time", start_time
              conn.hset redis_keys[:total], "finish_time", finish_time

              conn.expire redis_keys[:stats], REDIS_KEYS_TTL
              conn.expire redis_keys[:total], REDIS_KEYS_TTL
            end
          end
        end

        def method_missing(name, *args, &block)
          if block_given?
            measure(name, &block)
            self[name]
          else
            self[name] = args[0]
          end
        end

      end
    end
  end
end
