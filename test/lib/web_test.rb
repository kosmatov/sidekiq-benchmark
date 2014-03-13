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

        it "should display index without stats" do
          get '/benchmarks'
          last_response.status.must_equal 200
        end

        it "should display index with stats" do
          WorkerMock.new

          get '/benchmarks'
          last_response.status.must_equal 200
        end

        it "should remove benchmarks data" do
          WorkerMock.new

          Sidekiq.redis do |conn|
            keys = conn.keys "benchmark:*"
            keys.wont_be_empty
          end

          post '/benchmarks/remove'
          last_response.status.must_equal 302

          Sidekiq.redis do |conn|
            keys = conn.keys "benchmark:*"
            keys.must_be_empty
          end
        end
      end
    end
  end
end
