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
            assert metrics[metric_name]
          end

          assert @worker.bm_obj.start_time
          assert @worker.bm_obj.finish_time
          assert @worker.bm_obj.assigned_metric
        end

        it "should save metrics to redis" do
          Sidekiq.redis do |conn|
            total_time = conn.hget("#{@worker.benchmark_redis_base_key}:total", :job_time)
            assert total_time, "Total time: #{total_time.inspect}"

            metrics = conn.hkeys("#{@worker.benchmark_redis_base_key}:stats")
            assert metrics.any?, "Metrics: #{metrics.inspect}"
          end
        end
      end
    end
  end
end
