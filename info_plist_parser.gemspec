# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'info_plist_parser/version'

Gem::Specification.new do |spec|
  spec.name = "info_plist_parser"
  spec.version = InfoPlistParser::VERSION
  spec.authors = ["andrewleo"]
  spec.email = ["andrewleo@126.com"]
  spec.summary = "Info.plist Parser"
  spec.description = "Parse Info.plist in Apple Ipa"
  spec.homepage = "http://github.com/andrewleo/info_plist_parse"
  spec.license = "MIT"

  spec.files = `git ls-files -z`.split("\x0")
  spec.executables = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]
  spec.required_ruby_version = '~> 2.0'

  spec.add_runtime_dependency 'CFPropertyList', '~> 2.3.5'
  spec.add_runtime_dependency 'rubyzip', '>= 1.0.0'
  spec.add_runtime_dependency 'pngdefry', '~> 0.1.2'

  spec.add_development_dependency 'bundler', '~> 1.6'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec'
end
