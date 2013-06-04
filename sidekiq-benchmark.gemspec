# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'sidekiq-benchmark/version'

Gem::Specification.new do |gem|
  gem.name          = "sidekiq-benchmark"
  gem.version       = Sidekiq::Benchmark::VERSION
  gem.authors       = ["Konstantin Kosmatov"]
  gem.email         = ["key@kosmatov.ru"]
  gem.description   = %q{Benchmarks for Sidekiq}
  gem.summary       = %q{Adds benchmarking methods to Sidekiq workers, keeps metrics and adds tab to Web UI to let you browse them.}
  gem.homepage      = "https://github.com/kosmatov/sidekiq-benchmark/"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_development_dependency "sidekiq"
  gem.add_development_dependency "slim"
  gem.add_development_dependency "sinatra"
  gem.add_development_dependency "rake"
  gem.add_development_dependency "rack-test"
  gem.add_development_dependency "minitest", "~> 5"
end
