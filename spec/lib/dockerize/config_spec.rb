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

    context 'assigning a project directory' do
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

  describe 'accepting options' do
    describe 'dry-run' do
      it 'sets dry-run for -d' do
        run '. -d'
        config.dry_run?.should == true
      end

      it 'sets dry-run for --dry-run' do
        run '. --dry-run'
        config.dry_run?.should == true
      end

      it 'turns dry run off for --no-dry-run' do
        run '. --no-dry-run'
        config.dry_run?.should == false
      end

      it 'defaults dry run to off' do
        run '.'
        config.dry_run?.should == false
      end
    end

    describe 'quiet' do
      it 'sets quiet for -q' do
        run '. -q'
        config.quiet?.should == true
      end

      it 'sets quiet for --quiet' do
        run '. --quiet'
        config.quiet?.should == true

      end

      it 'sets no quiet for --no-quiet' do
        run '. --no-quiet'
        config.quiet?.should == false
      end

      it 'sets no quiet when when specified' do
        run '.'
        config.quiet?.should == false
      end
    end
  end
end
