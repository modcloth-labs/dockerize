# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
vendor = File.expand_path('../vendor', __FILE__)

$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
$LOAD_PATH.unshift(vendor) unless $LOAD_PATH.include?(vendor)

require 'dockerize/version'

Gem::Specification.new do |gem|
  gem.name          = 'dockerize'
  gem.version       = Dockerize::VERSION
  gem.authors       = ['Rafe Colton']
  gem.email         = ['r.colton@modcloth.com']
  gem.description   = 'Dockerizes your application'
  gem.summary       = 'Creates a templated Dockerfile and corresponding ' <<
                       'support files for easy deployment with docker.'
  gem.homepage      = 'https://github.com/modcloth-labs/dockerize'
  gem.license       = 'MIT'

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}) { |f| File.basename(f) }
  gem.bindir        = 'bin'
  gem.test_files    = gem.files.grep(%r{^spec/})
  gem.require_paths = %w(lib vendor)
  gem.required_ruby_version = '>= 1.9.3'

  gem.add_development_dependency 'rake'
  gem.add_development_dependency 'rspec'
  gem.add_development_dependency 'rubocop'

  gem.add_development_dependency 'pry' unless RUBY_PLATFORM == 'java'
  gem.add_development_dependency 'simplecov' unless RUBY_PLATFORM == 'java'

  gem.add_runtime_dependency 'colorize'
end
