module Sidekiq
  module Benchmark
    module Worker
      class Benchmark
        def save; end
        def set_redis_key(key); end
      end
    end
  end
end
