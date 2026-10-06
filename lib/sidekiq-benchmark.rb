require 'sidekiq/web'
require 'sidekiq-benchmark/web'

if Sidekiq::Web.respond_to?(:configure)
  Sidekiq::Web.configure do |config|
    config.register Sidekiq::Benchmark::Web, name: "benchmark", tab: "Benchmarks", index: "benchmarks"
  end
else
  Sidekiq::Web.register Sidekiq::Benchmark::Web
  Sidekiq::Web.tabs["Benchmarks"] = "benchmarks"
end

module Sidekiq
  module Benchmark
    REDIS_NAMESPACE = :benchmark
    TYPES_KEY = "#{REDIS_NAMESPACE}:types".freeze
    STAT_KEYS = %i[stats total]
    REDIS_KEYS_TTL = 3600 * 24 * 30

    autoload :Worker, 'sidekiq-benchmark/worker'
  end
end
