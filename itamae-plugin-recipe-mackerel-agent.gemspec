# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'itamae/plugin/recipe/mackerel-agent/version'

Gem::Specification.new do |spec|
  spec.name          = "itamae-plugin-recipe-mackerel-agent"
  spec.version       = Itamae::Plugin::Recipe::Mackerel::Agent::VERSION
  spec.authors       = ["mackerel"]
  spec.email         = ["platform+mackerel@hatena.ne.jp"]
  spec.summary       = %q{Itamae mackerel-agent recipe plugin}
  spec.description   = %q{Itamae mackerel-agent recipe plugin}
  spec.homepage      = 'https://github.com/mackerelio/itamae-plugin-recipe-mackerel-agent'
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "toml", "~> 0.1.2"

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
end
