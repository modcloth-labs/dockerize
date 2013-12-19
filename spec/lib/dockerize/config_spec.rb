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
      %w(-d --dry-run).each do |arg|
        it "sets dry-run for #{arg}" do
          run ". #{arg}"
          config.dry_run?.should == true
        end
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
      %w(-q --quiet).each do |arg|
        it "sets quiet for #{arg}" do
          run ". #{arg}"
          config.quiet?.should == true
        end
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

    describe 'force' do
      %w(-f --force).each do |arg|
        it "sets force for #{arg}" do
          run ". #{arg}"
          config.force?.should == true
        end
      end

      it 'sets no force for --no-force' do
        run '. --no-force'
        config.force?.should == false
      end

      it 'sets no force when when specified' do
        run '.'
        config.force?.should == false
      end
    end

    describe 'version' do
      let(:version) { Dockerize::VERSION }

      %w(-v --version).each do |arg|
        it "prints the version with #{arg}" do
          $stderr.should_receive(:puts).with("dockerize #{version}")
          expect { run arg }.to raise_error(SystemExit)
        end
      end
    end

    describe 'backup' do
      %w(-b --backup).each do |arg|
        it "sets backup for #{arg}" do
          run ". #{arg}"
          config.backup?.should == true
        end
      end

      it 'sets no backup for --no-backup' do
        run '. --no-backup'
        config.backup?.should == false
      end

      it 'sets backup by default' do
        run '.'
        config.backup?.should == true
      end
    end

    describe 'registry' do
      let(:registry) { 'foo' }

      %w(-r --registry).each do |arg|
        it "sets registry for #{arg}" do
          run ". #{arg} #{registry}"
          config.registry.should == registry
        end
      end

      it 'sets modcloth registry by default' do
        run '.'
        config.registry.should == 'quay.io/modcloth'
      end
    end

    describe 'project_name' do
      let(:project_name) { 'baz' }
      let(:subdir) { 'foobarbaz' }

      %w(-p --project-name).each do |arg|
        it "sets project name for #{arg}" do
          run ". #{arg} #{project_name}"
          config.project_name.should == project_name
        end
      end

      it 'sets the default to the project directory name' do
        tmpdir do |tmp|
          project_dir = "#{tmp}/#{subdir}"
          FileUtils.mkdir_p(project_dir)
          run project_dir
          config.project_name.should == subdir
        end
      end
    end

    describe 'template_dir' do
      it 'sets the default template dir to the top level' do
        run '.'
        config.template_dir.should == "#{top}/templates"
      end
    end
  end
end
