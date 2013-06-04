module Sidekiq
  module Benchmark
    module Worker

      def benchmark(id, options = {})
        bm = Benchmark.new Time.now

        yield(bm)

        bm.finish_time = Time.now
        bm.save id, benchmark_redis_base_key, options

        bm.set_redis_key benchmark_redis_type_key
        bm
      end

      def benchmark_redis_type_key
        @benchmark_redis_type_key ||= self.class.name.gsub('::', '_').downcase
      end

      def benchmark_redis_base_key
        @benchmark_redis_base_key ||= "benchmark:#{benchmark_redis_type_key}"
      end

      class Benchmark
        attr_reader :metrics, :start_time, :finish_time

        def initialize(start_time)
          @metrics = {}
          @start_time = start_time.to_f
        end

        def finish_time=(value)
          @finish_time = value.to_f
          @metrics[:job_time] = @finish_time - start_time
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
            conn.sadd "benchmark:types", key
          end
        end

        def save(id, redis_base_key, options = {})
          options.merge! id: id.to_i, start_time: start_time, finish_time: finish_time
          options.merge! @metrics

          job_time_key = @metrics[:job_time].round(1)

          Sidekiq.redis do |conn|
            conn.multi do
              conn.lpush "#{redis_base_key}:jobs", Sidekiq.dump_json(options)

              @metrics.each do |key, value|
                conn.hincrbyfloat "#{redis_base_key}:total", key, value
                conn.hincrby "#{redis_base_key}:stats", job_time_key, 1
              end

              conn.hsetnx "#{redis_base_key}:total", "start_time", start_time
              conn.hincrbyfloat "#{redis_base_key}:total", "job_time", @metrics[:job_time]
              conn.hset "#{redis_base_key}:total", "finish_time", finish_time
            end
          end
        end

      end
    end
  end
end
