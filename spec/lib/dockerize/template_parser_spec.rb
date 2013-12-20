# coding: utf-8

require 'dockerize/template_parser'

describe Dockerize::TemplateParser do
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

  subject(:parser) { described_class.new(contents) }

  it 'assigns the contents passed in as the raw text' do
    parser.raw_text.should == contents
  end

  describe 'retrieving template file contents' do
    context 'parsing the yaml' do
      it 'retrieves the correct header vars' do
        parser.yaml_metadata.should == {
          'filename' => filename,
          'filter' => 'Baxter the Dog',
          'foo' => 'pasta',
        }
      end

      it 'retrieves the correct erb content' do
        parser.yaml_content.should == <<-EOB.gsub(/^ +/, '')
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
        parser.parsed_erb.should == parsed_contents
      end
    end
  end

  describe 'writing the file' do
    let(:writer) { Dockerize::DocumentWriter.new(filename) }

    it 'creates the file' do
      tmpdir do |tmp|
        run tmp
        expect { parser.write_with writer }.to change {
          File.exists?("#{tmp}/#{filename}")
        }
      end
    end

    it 'writes the correct contents to the file' do
      tmpdir do |tmp|
        run tmp
        parser.write_with writer
        File.read("#{tmp}/#{filename}").should == parsed_contents
      end
    end
  end
end
