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
  gem.license       = 'MIT'

  gem.files         = `git ls-files | grep -Ev '^(examples)'`.split("\n")
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_dependency "chartkick", '>= 1.1.1'

  gem.add_development_dependency "sidekiq"
  gem.add_development_dependency "rake"
  gem.add_development_dependency "rack-test"
  gem.add_development_dependency "minitest", "~> 5"
  gem.add_development_dependency "coveralls"
  gem.add_development_dependency "pry"
  gem.add_development_dependency 'delorean', '~> 2.1'
end
