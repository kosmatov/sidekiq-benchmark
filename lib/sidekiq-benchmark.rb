require 'sidekiq/web'
require 'sidekiq-benchmark/web'

Sidekiq::Web.register Sidekiq::Benchmark::Web
Sidekiq::Web.tabs["Benchmarks"] = "benchmarks"

module Sidekiq
  module Benchmark
    REDIS_NAMESPACE = :benchmark
    TYPES_KEY = "#{REDIS_NAMESPACE}:types".freeze
    REDIS_KEYS_TTL = 3600 * 24 * 30

    autoload :Worker, 'sidekiq-benchmark/worker'
  end
end

