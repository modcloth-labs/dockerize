# coding: utf-8

require 'dockerize/cli'
require 'dockerize/error'

describe Dockerize::Cli do
  let(:config) { Dockerize::Config }

  describe 'accepting arguments' do
    it 'explodes if no arguments are provided' do
      expect { run }.to raise_error(
        Dockerize::Error::MissingRequiredArgument
      )
    end

    it 'does not explode if at least one argument is provided' do
      tmpdir do |tmp|
        expect { run tmp }.to_not raise_error
      end
    end
  end

  describe 'setting the project directory' do
    let(:pwd) { Dir.pwd }

    context 'command line arguments are provided' do
      it 'sets the project dir to PWD when a . is specified' do
        run '.'
        config.project_dir.should == pwd
      end

      it 'sets the project dir to the first argument provided' do
        tmpdir do |tmp|
          run tmp
          config.project_dir.should == tmp
        end
      end
    end
  end
end
