module Sidekiq
  module Benchmark
    module Worker

      def benchmark(options = {})
        @benchmark ||= Benchmark.new Time.now, benchmark_redis_type_key, options

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
        REDIS_NAMESPACE = :benchmark

        attr_reader :metrics, :start_time, :finish_time, :redis_key

        def initialize(start_time, redis_key, options)
          @metrics = {}
          @options = options
          @start_time = start_time.to_f

          @redis_key = "#{REDIS_NAMESPACE}:#{redis_key}"
          set_redis_key redis_key
        end

        def finish
          @finish_time = Time.now.to_f
          @metrics[:job_time] = @finish_time - start_time
          save
        end

        def method_missing(name, *args)
          if block_given?
            start_time = Time.now

            yield

            finish_time = Time.now
            value = finish_time.to_f - start_time.to_f
          else
            value = args[0].to_f
          end

          @metrics[name] = value
        end

        def set_redis_key(key)
          Sidekiq.redis do |conn|
            conn.sadd "#{REDIS_NAMESPACE}:types", key
          end
        end

        def save
          job_time_key = @metrics[:job_time].round(1)

          Sidekiq.redis do |conn|
            conn.multi do
              @metrics.each do |key, value|
                conn.hincrbyfloat "#{redis_key}:total", key, value
              end

              conn.hincrby "#{redis_key}:stats", job_time_key, 1

              conn.hsetnx "#{redis_key}:total", "start_time", start_time
              conn.hset "#{redis_key}:total", "finish_time", finish_time
            end
          end
        end

      end
    end
  end
end
