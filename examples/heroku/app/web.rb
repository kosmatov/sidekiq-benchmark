module Sidekiq
  module Benchmark
    module Sample
      WEB_DIR = File.expand_path("../../", __FILE__).freeze
      VIEW_PATH = File.join(WEB_DIR, "views", "generate.erb").freeze

      def self.registered(app)
        app.get "/benchmarks/generate" do
          erb File.read VIEW_PATH
        end

        app.post "/benchmarks/generate" do
          10.times do
            Worker.defer
          end

          redirect "#{root_path}benchmarks"
        end
      end
    end
  end
end
