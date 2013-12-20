# coding: utf-8

require 'dockerize/from_template'

describe Dockerize::FromTemplate do
  # set up template context from config & Config
  # render the template
  # get the output file name from the template
  # allow someone to pass in the path to the template

  let(:filename) { 'Dockerfile' }
  let(:contents) do
    <<-EOB.gsub(/^ {4}/, '')
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
  let(:parsed_contents) do
    <<-EOB.gsub(/^ +/, '')
    This is the first line

    This is the second line

    This has some erb interpolation: "pasta"
    EOB
  end

  subject(:writer) { described_class.new(contents) }

  describe 'target document name' do
    it 'provides a valid output_target' do
      expect { writer.output_target }.to_not raise_error
    end
  end

  describe 'retrieving template file contents' do
    it 'reads in the raw file contents' do
      tmpdir do |tmp|
        file_path = "#{tmp}/foo"
        File.open(file_path, 'w') do |f|
          f.print(contents)
        end

        described_class.new(file_path).raw_content.should == contents
      end
    end

    it 'assumes the text given that is not a file is the content' do
      writer.raw_content.should == contents
    end

    context 'parsing the yaml' do
      it 'retrieves the correct header vars' do
        writer.yaml_metadata.should == {
          'filename' => filename,
          'filter' => 'Baxter the Dog',
          'foo' => 'pasta',
        }
      end

      it 'retrieves the correct erb content' do
        writer.yaml_content.should == <<-EOB.gsub(/^ +/, '')
        This is the first line

        This is the second line

        This has some erb interpolation: "<%= foo %>"
        EOB
      end
    end

    context 'parsing the erb' do
      it 'sets the correct variables' do

      end

      it 'produces the correct output text' do
        writer.parsed_erb.should == parsed_contents
      end
    end
  end

  describe 'writing the file' do
    it 'creates the file' do
      tmpdir do |tmp|
        run tmp
        expect { writer.write }.to change {
          File.exists?("#{tmp}/#{filename}")
        }
      end
    end

    it 'writes the correct contents to the file' do
      tmpdir do |tmp|
        run tmp
        writer.write
        File.read("#{tmp}/#{filename}").should == parsed_contents
      end
    end
  end
end
