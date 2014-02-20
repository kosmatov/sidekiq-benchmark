require 'test_helper'
require 'sidekiq-benchmark/testing'

class Sidekiq::Benchmark::TestingTest < Minitest::Spec
  describe 'Testing' do
    before do
      Sidekiq::Benchmark::Test.flush_db
      @worker = Sidekiq::Benchmark::Test::WorkerMock.new
    end

    it "save nothing to redis" do
      Sidekiq.redis do |conn|
        total_time = conn.hget("#{@worker.benchmark.redis_key}:total", :job_time)
        total_time.must_be_nil
      end
    end
  end
end
