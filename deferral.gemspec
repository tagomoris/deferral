
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "deferral/version"

Gem::Specification.new do |spec|
  spec.name          = "deferral"
  spec.version       = Deferral::VERSION
  spec.authors       = ["TAGOMORI Satoshi"]
  spec.email         = ["tagomoris@gmail.com"]

  spec.summary       = %q{Provide golang style defer method in Ruby}
  spec.description   = %q{Provide a method to release/collect resources in deferred way}
  spec.homepage      = "https://github.com/tagomoris/deferral"
  spec.license       = "MIT"

  spec.required_ruby_version = ">= 2.4.0" # To use Refine with module (not class)

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "test-unit"
end
