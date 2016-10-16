require 'chartkick'

module Sidekiq
  module Benchmark
    module Web
      WEB_DIR = File.expand_path("../../../web", __FILE__).freeze
      JS_DIR = File.join(WEB_DIR, "assets", "javascripts").freeze
      VIEW_PATH = File.join(WEB_DIR, "views", "benchmarks.erb").freeze

      def self.registered(app)
        app.helpers Chartkick::Helper

        app.get '/benchmarks/javascripts/chartkick.js' do
          body = File.read File.join(JS_DIR, 'chartkick.js')
          headers = {
            'Content-Type' => 'application/javascript',
            'Cache-Control' => 'public, max-age=84600'
          }
          [200, headers, [body]]
        end

        app.get "/benchmarks" do
          @charts = {}

          Sidekiq.redis do |conn|
            @types = conn.smembers TYPES_KEY
            @types.each do |type|
              @charts[type] = STAT_KEYS.reduce({}) { |a, e| a[e] = []; a }

              total_key = "#{REDIS_NAMESPACE}:#{type}:total"
              total_keys = conn.hkeys(total_key) - %w(start_time job_time finish_time)

              total_time = conn.hget total_key, :job_time
              total_time = total_time.to_f
              total_keys.each do |key|
                value = conn.hget total_key, key
                @charts[type][:total] << [key, value.to_f.round(2)]
              end

              stats = conn.hgetall "#{REDIS_NAMESPACE}:#{type}:stats"
              stats.each do |key, value|
                @charts[type][:stats] << [key.to_f, value.to_i]
              end

              @charts[type][:stats].sort! { |a, b| a[0] <=> b[0] }
              @charts[type][:stats].map! { |a| [a[0].to_s, a[1]] }
            end
          end

          erb File.read(VIEW_PATH)
        end

        app.post "/benchmarks/remove" do
          Sidekiq.redis do |conn|
            keys = STAT_KEYS.map { |key| "#{REDIS_NAMESPACE}:#{params[:type]}:#{key}" }
            conn.srem TYPES_KEY, params[:type]
            conn.del keys
          end

          redirect "#{root_path}benchmarks"
        end
        app.post "/benchmarks/remove_all" do
          Sidekiq.redis do |conn|
            types = conn.smembers TYPES_KEY
            keys = STAT_KEYS.map do |key|
              types.map { |type| "#{REDIS_NAMESPACE}:#{type}:#{key}" }
            end.flatten
            keys << TYPES_KEY
            conn.del keys
          end

          redirect "#{root_path}benchmarks"
        end
      end
    end
  end
end
