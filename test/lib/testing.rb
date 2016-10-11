require 'test_helper'

class Sidekiq::Benchmark::TestingTest < Minitest::Spec
  require 'sidekiq-benchmark/testing'

  describe 'Testing' do
    before do
      Sidekiq::Benchmark::Test.flush_db
      @worker = Sidekiq::Benchmark::Test::WorkerMock.new
    end

    it "save nothing to redis" do
      Sidekiq.redis do |conn|
        total_time = conn.hget(@worker.benchmark.redis_keys[:total], :job_time)
        total_time.must_be_nil
      end
    end

    it "run code in bm blocks" do
      @worker.counter.wont_equal 0
    end
  end
end
