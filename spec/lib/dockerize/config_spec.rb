# coding: utf-8

require 'tmpdir'
require 'dockerize/config'
require 'dockerize/error'

describe Dockerize::Config do
  subject(:config) { described_class }

  describe 'configuring the project directory' do
    it 'specifies a project directory' do
      config.should respond_to(:project_dir=)
    end

    context 'when setting a project directory' do
      let(:bogus_dir) { '/foobarbaz' }

      it 'explodes when the project directory does not exist' do
        expect { described_class.project_dir = bogus_dir }.to raise_error(
          Dockerize::Error::NonexistentProjectDirectory
        )
      end

      it 'explodes when the project directory is not a directory' do
        expect { described_class.project_dir = $PROGRAM_NAME }.to raise_error(
          Dockerize::Error::InvalidProjectDirectory
        )
      end

      it 'does not explode if the project directory is valid' do
        tmpdir do |tmp|
          expect { described_class.project_dir = tmp }.to_not raise_error
        end
      end
    end
  end
end
