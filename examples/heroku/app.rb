require 'sidekiq'
require 'sidekiq-benchmark'
require './app/worker'
require './app/web'

Sidekiq::Web.register Sidekiq::Benchmark::Sample
