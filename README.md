# Sidekiq::Benchmark
 
Adds benchmarking methods to Sidekiq workers, keeps metrics and adds tab to Web UI to let you browse them.

## Installation

Add this line to your application's Gemfile:

    gem 'sidekiq-benchmark'

And then execute:

    $ bundle

## Requirements

Redis 2.6.0 or newer required

## Usage

```ruby
class SampleWorker
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
    end
  end

end
```
## Web UI
![Web UI](https://github.com/kosmatov/sidekiq-benchmark/raw/master/examples/web-ui.png)

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
