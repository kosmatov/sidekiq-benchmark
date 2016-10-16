require 'test_helper'

module Sidekiq
  module Benchmark
    module Test
      describe "Web extention" do
        include Rack::Test::Methods

        def app
          @app ||= Sidekiq::Web
        end

        before do
          Test.flush_db
        end

        it "display index without stats" do
          get '/benchmarks'
          last_response.status.must_equal 200
        end

        it "display index with stats" do
          WorkerMock.new

          get '/benchmarks'
          last_response.status.must_equal 200
        end

        it "remove all benchmarks data" do
          WorkerMock.new

          Sidekiq.redis { |conn| conn.keys("benchmark:*").wont_be_empty }

          post '/benchmarks/remove_all'
          last_response.status.must_equal 302

          Sidekiq.redis { |conn| conn.keys("benchmark:*").must_be_empty }
        end

        it "remove benchmark data" do
          WorkerMock.new

          Sidekiq.redis { |conn| conn.keys("benchmark:sidekiq_benchmark_test_workermock:*").wont_be_empty }

          post '/benchmarks/remove', type: :sidekiq_benchmark_test_workermock
          last_response.status.must_equal 302

          Sidekiq.redis { |conn| conn.keys("benchmark:sidekiq_benchmark_test_workermock:*").must_be_empty }
        end
      end
    end
  end
end
