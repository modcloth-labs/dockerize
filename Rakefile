#!/usr/bin/env rake
# vim:fileencoding=utf-8

require 'bundler/gem_tasks'
require 'rspec/core/rake_task'

desc 'Run rubocop'
task :rubocop do
  sh('rubocop --format simple'){ |ok, _| ok || abort }
end

RSpec::Core::RakeTask.new(:spec) do |t|
  t.rspec_opts = '--format documentation'
end

task default: [:spec, :rubocop]
