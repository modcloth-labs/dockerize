# coding: utf-8

require 'dockerize/cli'
require 'dockerize/error'

describe Dockerize::Cli do
  let(:config) { Dockerize::Config }
  let(:cli) { Dockerize::Cli }

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

  describe 'parsing templates' do
    let(:filename) { 'foo' }
    let(:template) do
      <<-EOB.gsub(/^ {6}/, '')
      ---
      filename: '#{filename}'
      filter: 'Baxter the Dog'
      foo: 'pasta'
      ---
      content: |
        This is the first line

        This is the second line

        This has some erb interpolation: "<%= foo %>"
      EOB
    end
    let(:parsed_template) do
      <<-EOB.gsub(/^ +/, '')
      This is the first line

      This is the second line

      This has some erb interpolation: "pasta"
      EOB
    end

    it 'writes files from the given templates' do
      tmpdir do |project_dir|
        tmpdir do |template_dir|
          File.open("#{template_dir}/template.erb.yml", 'w+') do |f|
            f.puts template
          end
          run "#{project_dir} --template-dir #{template_dir}"
          expect { cli.send(:handle_templates) }.to change {
            File.exists?("#{project_dir}/#{filename}")
          }
        end
      end
    end

    it 'writes correct content to the target files' do
      tmpdir do |project_dir|
        tmpdir do |template_dir|
          File.open("#{template_dir}/template.erb.yml", 'w+') do |f|
            f.puts template
          end
          run "#{project_dir} --template-dir #{template_dir}"
          cli.send(:handle_templates)
          File.read("#{project_dir}/#{filename}").should == parsed_template
        end
      end
    end
  end
end
