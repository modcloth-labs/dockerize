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
  cmd = cmd.split(' ') if cmd.class == String
  Dockerize::Cli.send(:args=, cmd)
  Dockerize::Cli.send(:ensure_project_dir)
  Dockerize::Config.parse(cmd)
  Dockerize::Cli.send(:set_out_stream)
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

def top
  @top ||= File.expand_path('..', File.dirname(__FILE__))
end
