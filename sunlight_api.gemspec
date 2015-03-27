# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'sunlight_api/version'

Gem::Specification.new do |spec|
  spec.name          = "sunlight_api"
  spec.version       = SunlightApi::VERSION
  spec.authors       = ["The Tyrel Corporation"]
  spec.email         = ["tyrel@thetyrelcorporation.com"]

  spec.summary       = %q{Access specifications and stock levels for sunlight supplies product line}
  spec.description   = %q{Get product details and inventory levels on a per wherehouse basis for Sunlight Supplies Inc. Product Line}
  spec.homepage      = "https://github.com/thetyrelcorporation/sunlight_api"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.8"
  spec.add_development_dependency "rake", "~> 10.0"
end
