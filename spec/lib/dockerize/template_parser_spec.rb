# coding: utf-8

require 'dockerize/template_parser'

describe Dockerize::TemplateParser do
  let(:filename) { 'Dockerfile' }
  let(:contents) do
    <<-EOB.gsub(/^ +/, '')
    <% self.filename = '#{filename}' -%>
    <% self.filter = 'Baxter the Dog' -%>
    <% self.foo = 'pasta' -%>
    <% self.executable = true -%>
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
    context 'parsing the template' do
      it 'retrieves the correct header vars' do
        parser.parsed_erb
        parser.metadata.should == {
          filename: filename,
          filter: 'Baxter the Dog',
          foo: 'pasta',
          executable: true
        }
      end
    end

    context 'parsing the erb' do
      it 'produces the correct output text' do
        parser.parsed_erb.should == parsed_contents
      end
    end
  end

  describe 'writing the file' do
    let(:writer) { Dockerize::DocumentWriter.new }

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

    it 'makes the file executable' do
      tmpdir do |tmp|
        run tmp
        parser.write_with writer
        File.executable?("#{tmp}/#{filename}").should == true
      end
    end
  end

  describe 'handling invalid templates' do
    let(:invalid_erb) do
      <<-ERB.gsub(/^\s+/, '')
      This is the first line

      This is the second line

      This has some erb interpolation: <%= foo #%>
      ERB
    end

    context 'invalid erb' do
      subject(:invalid_erb_parser) do
        described_class.new(invalid_erb)
      end

      it 'does not explode when given invalid erb' do
        expect { invalid_erb_parser.parsed_erb }.to_not raise_error
      end

      it 'returns nil as the parsed content' do
        invalid_erb_parser.parsed_erb.should be_nil
      end
    end
  end
end
