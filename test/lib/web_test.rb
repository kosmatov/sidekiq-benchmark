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
          last_response.status.must_equal 200, last_response.body
        end
      end
    end
  end
end
