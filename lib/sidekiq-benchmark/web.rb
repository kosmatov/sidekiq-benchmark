require 'sinatra/assetpack'
require 'chartkick'

module Sidekiq
  module Benchmark
    module Web
      def self.registered(app)
        web_dir = File.expand_path("../../../web", __FILE__)
        js_dir = File.join(web_dir, "assets", "javascripts")

        app.helpers Chartkick::Helper
        app.register Sinatra::AssetPack

        app.assets {
          serve '/js', from: js_dir
        }

        app.get "/benchmarks" do
          @charts = {}

          Sidekiq.redis do |conn|
            @types = conn.smembers "benchmark:types"
            @types.each do |type|
              @charts[type] = { total: [], stats: [] }

              total_keys = conn.hkeys("benchmark:#{type}:total") -
                ['start_time', 'job_time', 'finish_time']

              total_time = conn.hget "benchmark:#{type}:total", :job_time
              total_time = total_time.to_f
              total_keys.each do |key|
                value = conn.hget "benchmark:#{type}:total", key
                @charts[type][:total] << [key, value.to_f.round(2)]
              end

              stats = conn.hgetall "benchmark:#{type}:stats"
              stats.each do |key, value|
                @charts[type][:stats] << [key.to_f, value.to_i]
              end

              @charts[type][:stats].sort! { |a, b| a[0] <=> b[0] }
              @charts[type][:stats].map! { |a| [a[0].to_s, a[1]] }
            end
          end

          view_path = File.join(web_dir, "views", "benchmarks.erb")
          template = File.read view_path
          render :erb, template
        end

        app.post "/benchmarks/remove" do
          Sidekiq.redis do |conn|
            keys = conn.keys "benchmark:*"
            conn.del keys
          end

          redirect "#{root_path}benchmarks"
        end
      end
    end
  end
end
