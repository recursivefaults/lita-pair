Gem::Specification.new do |spec|
  spec.name          = "lita-pair"
  spec.version       = "0.2.4"
  spec.authors       = ["Ryan Latta"]
  spec.email         = ["recursive.faults@gmail.com"]
  spec.description   = "A lita handler that will help with pair programming rotations"
  spec.summary       = "Automate your programming pairs"
  spec.homepage      = "https://github.com/recursive.faults/lita-pair"
  spec.license       = "MIT"
  spec.metadata      = { "lita_plugin_type" => "handler" }

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "lita", ">= 4.6"

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "pry-byebug"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rack-test"
  spec.add_development_dependency "rspec", ">= 3.0.0"
end
