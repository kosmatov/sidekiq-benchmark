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
        REDIS_NAMESPACE = :benchmark

        attr_reader :metrics, :start_time, :finish_time, :redis_key

        def initialize(worker, redis_key, options)
          @metrics = {}
          @worker = worker
          @options = options
          @start_time = Time.now

          @redis_key = "#{REDIS_NAMESPACE}:#{redis_key}"
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
          
          Sidekiq.logger.info "Benchmark #{name}: #{t1 - t0} sec." if @options[:log]

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

        def method_missing(name, *args, &block)
          if block_given?
            measure(name, &block)
            self[name]
          else
            self[name] = args[0]
          end
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
