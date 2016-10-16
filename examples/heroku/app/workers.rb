module Sidekiq
  module Benchmark
    module Sample
      class Worker
        include Sidekiq::Worker
        include Sidekiq::Benchmark::Worker

        def self.defer
          perform_async
        end

        def perform
          benchmark do |bm|
            max = Random.new.rand(10000..15000)
            bm.first_metric do
              (1..max).reduce(:*)
            end

            bm.second_metric do
              max -= 5000
              (1..max).reduce(:*)
            end

            bm.third_metric do
              max -= 2000
              (1..max).reduce(:*)
            end
          end
        end
      end

      OtherWorker = Class.new Worker
    end
  end
end
