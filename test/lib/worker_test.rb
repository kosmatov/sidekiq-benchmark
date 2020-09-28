require 'test_helper'

module Sidekiq
  module Benchmark
    module Test

      class WorkerTest < Minitest::Spec
        include Sidekiq::Benchmark::Worker

        before do
          Test.flush_db
          @worker = WorkerMock.new
        end

        it "should collect metrics" do
          metrics = @worker.benchmark.metrics

          @worker.metric_names.each do |metric_name|
            _(metrics[metric_name]).wont_be_nil
          end

          _(@worker.benchmark.start_time).wont_be_nil
          _(@worker.benchmark.finish_time).wont_be_nil
          _(metrics[:assigned_metric]).must_equal @worker.assigned_metric
        end

        it 'should add up metrics' do
          worker = ContinuingWorkerMock.new
          metrics = worker.benchmark.metrics

          assert_in_delta metrics[:continued_metric], 2, 0.2
        end

        it "should save metrics to redis" do
          Sidekiq.redis do |conn|
            total_time = conn.hget(@worker.benchmark.redis_keys[:total], :job_time)
            _(total_time).wont_be_nil

            metrics = conn.hkeys(@worker.benchmark.redis_keys[:stats])
            _(metrics).wont_be_empty
          end
        end

        it "should collect metrics with alter syntax" do
          worker = AlterWorkerMock.new
          metrics = worker.benchmark.metrics

          Sidekiq.redis do |conn|
            metric_set = conn.hkeys(worker.benchmark.redis_keys[:stats])
            _(metric_set).must_be_empty
          end

          worker.metric_names.each do |metric_name|
            _(metrics[metric_name]).wont_be_nil
          end

          _(worker.benchmark.finish_time).must_be_nil
          worker.finish
          _(worker.benchmark.finish_time).wont_be_nil

          Sidekiq.redis do |conn|
            metric_set = conn.hkeys(worker.benchmark.redis_keys[:stats])
            _(metric_set).wont_be_empty
          end
        end

        it "should allow benchmark methods" do
          worker = AlterWorkerMock.new
          value  = worker.benchmark.call(:multiply, 4, 4)

          _(value).must_equal 16
          _(worker.benchmark.metrics[:multiply]).wont_be_nil
        end

      end
    end
  end
end
