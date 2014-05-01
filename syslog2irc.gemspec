# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'syslog2irc/version'

Gem::Specification.new do |spec|
  spec.name          = "syslog2irc"
  spec.version       = Syslog2irc::VERSION
  spec.authors       = ["Frerichs"]
  spec.email         = ["frerichs@fremaks.de"]
  spec.summary       = %q{TODO: Write a short summary. Required.}
  spec.description   = %q{TODO: Write a longer description. Optional.}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "syslog_protocol"
  spec.add_development_dependency "string-irc"
  spec.add_development_dependency "obscenity"

end
