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
          metrics = @worker.bm_obj.metrics

          @worker.metric_names.each do |metric_name|
            metrics[metric_name].wont_be_nil
          end

          @worker.bm_obj.start_time.wont_be_nil
          @worker.bm_obj.finish_time.wont_be_nil
          metrics[:assigned_metric].must_equal @worker.assigned_metric
        end

        it "should save metrics to redis" do
          Sidekiq.redis do |conn|
            total_time = conn.hget("#{@worker.benchmark.redis_key}:total", :job_time)
            total_time.wont_be_nil

            metrics = conn.hkeys("#{@worker.benchmark.redis_key}:stats")
            metrics.wont_be_empty
          end
        end
      end
    end
  end
end
