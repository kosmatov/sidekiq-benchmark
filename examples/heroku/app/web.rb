module Sidekiq
  module Benchmark
    module Sample

      def self.registered(app)
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
