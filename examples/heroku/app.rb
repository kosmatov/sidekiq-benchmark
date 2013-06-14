require 'sidekiq'
require 'sidekiq-benchmark'
require './app/worker'
require './app/web'

Sidekiq::Web.register Sidekiq::Benchmark::Sample

REDIS_CONFIG = { namespace: :sample }

Sidekiq.configure_server do |config|
  config.redis = REDIS_CONFIG
end

Sidekiq.configure_client do |config|
  config.redis = REDIS_CONFIG
end
