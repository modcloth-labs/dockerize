# coding: utf-8

require 'rubygems'
require 'bundler/setup'
require 'simplecov' unless RUBY_PLATFORM == 'java'
require 'pry' unless RUBY_PLATFORM == 'java'
require 'tmpdir'
require 'colored'

def tmpdir(&block)
  Dir.mktmpdir('dockerize-spec') do |tmp|
    yield tmp
  end
end

def run(cmd = [])
  if cmd.class == String
    Dockerize::Cli.run(cmd.split(' '))
  elsif cmd.class == Array
    Dockerize::Cli.run(cmd)
  else
    fail 'Invalid command'
  end
end

RSpec.configure do |config|
  config.before(:each) do
    $stdout.stub(:print)
    $stdout.stub(:puts)
  end
end

unless RUBY_PLATFORM == 'java'
  {
    output: $stdout.clone,
    prompt_name: 'dockerize',
  }.map do |k, v|
    Pry.config.send(:"#{k}=", v)
  end
end
