require 'sidekiq'
require 'sidekiq-benchmark'
require './app/worker'
require './app/web'

Sidekiq::Web.register Sidekiq::Benchmark::Sample

Sidekiq.configure_server do |config|
  config.redis = { namespace: :sample }
end

Sidekiq.configure_client do |config|
  config.redis = { namespace: :sample }
end
