# coding: utf-8

require 'rubygems'
require 'bundler/setup'
require 'simplecov' unless RUBY_PLATFORM == 'java'
require 'tmpdir'

def tmpdir(&block)
  Dir.mktmpdir('dockerize-spec') do |tmp|
    yield tmp
  end
end
