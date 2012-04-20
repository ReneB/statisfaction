# -*- encoding: utf-8 -*-
require File.expand_path('../lib/statisfaction/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = %q{Lennaert Meijvogel}
  gem.email         = %q{l.meijvogel@yahoo.co.uk}
  gem.description   = %q{Adds statistics collection to any Ruby/Rails class}
  gem.summary       = %q{Adds statistics collection to any Ruby/Rails class}
  gem.homepage      = "http://rubygems.org/gems/statisfaction"

  gem.add_dependency('rails', '>= 3.0.0')

  gem.add_development_dependency("rspec", ">= 2.0.0")

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "statisfaction"
  gem.require_paths = ["lib"]
  gem.version       = Statisfaction::VERSION
end
