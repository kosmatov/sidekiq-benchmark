require 'minitest/autorun'
require 'minitest/pride'

require 'coveralls'
Coveralls.wear! do
  add_filter '/test/'
end

ENV['RACK_ENV'] = 'test'

require 'bundler/setup'
require 'rack/test'

require 'sidekiq'
require 'sidekiq/util'
require 'sidekiq-benchmark'

require 'delorean'
require 'pry'

REDIS = Sidekiq::RedisConnection.create url: "redis://localhost/15"
Bundler.require

module Sidekiq
  module Benchmark
    module Test

      class WorkerMock
        include Sidekiq::Worker
        include Sidekiq::Benchmark::Worker

        attr_reader :bm_obj, :metric_names, :assigned_metric, :counter

        def initialize
          @assigned_metric = 0.1
          @counter = 0

          benchmark do |bm|
            bm.test_metric do
              2.times do |i|
                bm.send("nested_test_metric_#{i}") do
                  Delorean.jump 1
                  @counter += 100500
                end
              end
            end

            bm.assigned_metric @assigned_metric
          end

          @metric_names = [:test_metric, :nested_test_metric_1, :job_time]
        end
      end

      class AlterWorkerMock < WorkerMock
        def initialize
          benchmark.test_metric do
            Delorean.jump 1
          end

          benchmark.other_metric do
            Delorean.jump 1
          end

          @metric_names = [:test_metric, :other_metric]
        end

        def multiply(a, b)
          a * b
        end

        def finish
          benchmark.finish
        end
      end

      class ContinuingWorkerMock < WorkerMock
        def initialize
          benchmark do |bm|
            bm.continued_metric do
              Delorean.jump 1
            end

            bm.continued_metric do
              Delorean.jump 1
            end
          end
        end
      end

      def self.flush_db
        Sidekiq.redis = REDIS
        Sidekiq.redis do |conn|
          conn.flushdb
        end
      end

    end
  end
end
