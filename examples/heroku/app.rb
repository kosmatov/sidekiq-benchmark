require 'sidekiq'
require 'sidekiq-benchmark'
require_relative 'app/workers'
require_relative 'app/web'

Sidekiq::Web.register Sidekiq::Benchmark::Sample
