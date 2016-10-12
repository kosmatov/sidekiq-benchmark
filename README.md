# Sidekiq::Benchmark
[![Gem Version](https://badge.fury.io/rb/sidekiq-benchmark.png)](https://rubygems.org/gems/sidekiq-benchmark)
[![Code Climate](https://codeclimate.com/github/kosmatov/sidekiq-benchmark.png)](https://codeclimate.com/github/kosmatov/sidekiq-benchmark)
[![Build Status](https://travis-ci.org/kosmatov/sidekiq-benchmark.png)](https://travis-ci.org/kosmatov/sidekiq-benchmark)
[![Coverage Status](https://coveralls.io/repos/kosmatov/sidekiq-benchmark/badge.png?branch=master)](https://coveralls.io/r/kosmatov/sidekiq-benchmark)

Adds benchmarking methods to
[Sidekiq](https://github.com/mperham/sidekiq) workers, keeps metrics and adds tab to Web UI to let you browse them.

## Installation

Add this line to your application's Gemfile:

    gem 'sidekiq-benchmark'

And then execute:

    $ bundle

## Requirements

From version 0.5.0 works with Sidekiq 4.2 or newer

## Usage

```ruby
class SampleWorker
  include Sidekiq::Worker
  include Sidekiq::Benchmark::Worker

  def perform(id)
    benchmark.first_metric do
      100500.times do something end
    end

    benchmark.second_metric do
      42.times do anything end
    end

    benchmark.finish
  end
end

class OtherSampleWorker
  include Sidekiq::Worker
  include Sidekiq::Benchmark::Worker

  def perform(id)
    benchmark do |bm|
      bm.some_metric do
        100500.times do
        end
      end

      bm.other_metric do
        something_code
      end

      bm.some_metric do
        # some_metric measure continues
      end
    end
    # if block given, yield and finish
  end

end
```
## Examples

### Web UI

![Web UI](https://github.com/kosmatov/sidekiq-benchmark/raw/master/examples/web-ui.png)

### Sample Apps

[Heroku App](http://sidekiq-benchmark.herokuapp.com/benchmarks)

## Testing sidekiq workers

When you use [Sidekiq::Testing](https://github.com/mperham/sidekiq/wiki/Testing) you
must load `sidekiq-benchmark/testing` to stop saving benchmark data to redis.
Just add next code to your test or spec helper:

```ruby
require 'sidekiq-benchmark/testing'
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
