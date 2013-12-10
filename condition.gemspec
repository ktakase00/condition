# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'condition/version'

Gem::Specification.new do |spec|
  spec.name          = "condition"
  spec.version       = Condition::VERSION
  spec.authors       = ["aoyagikouhei"]
  spec.email         = ["aoyagi.kouhei@gmail.com"]
  spec.description   = %q{Condition Test}
  spec.summary       = %q{Condition Test}
  spec.homepage      = "https://github.com/aoyagikouhei/condition"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "pg"
  spec.add_development_dependency "sequel"
  spec.add_development_dependency "mongo"
  spec.add_development_dependency "bson_ext"
  spec.add_development_dependency "redis"
  spec.add_dependency "roo"
  spec.add_dependency "json"
end
