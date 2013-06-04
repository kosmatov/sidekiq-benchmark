require 'sidekiq/web'
require 'sidekiq/benchmark/web'

module Sidekiq
  module Benchmark
    autoload :Worker, 'sidekiq/benchmark/worker'
    autoload :Version, 'sidekiq/benchmark/version'
  end
end

Sidekiq::Web.register Sidekiq::Benchmark::Web
Sidekiq::Web.tabs["Benchmarks"] = "benchmarks"
