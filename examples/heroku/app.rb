require 'sidekiq'
require 'sidekiq-benchmark'
require './app/workers'
require './app/web'

Sidekiq::Web.register Sidekiq::Benchmark::Sample
