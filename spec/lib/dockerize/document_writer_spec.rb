# coding: utf-8

require 'dockerize/document_writer'
require 'fileutils'

describe Dockerize::DocumentWriter do
  subject(:writer) { described_class.new }

  describe 'determining file path to write' do
    context 'no document_name is specified' do
      it 'raises an error' do
        run '.'
        expect { writer.output_target }.to raise_error(
          Dockerize::Error::DocumentNameNotSpecified
        )
      end
    end

    context 'document name is specified' do
      it 'produces the correct document path' do
        tmpdir do |tmp|
          run tmp
          writer.stub(:document_name).and_return('foo_file')
          writer.output_target.should == "#{tmp}/foo_file"
        end
      end
    end
  end

  describe 'writing' do
    let(:filename) { 'foo_file' }
    before(:each) { writer.stub(:document_name).and_return(filename) }

    context 'dry run' do
      it 'writes to standard out' do
        tmpdir do |tmp|
          run %W(#{tmp} --dry-run)
          $stdout.should_receive(:print).with('12345')
          writer.write('12345')
        end
      end

      it 'writes nothing to its file' do
        tmpdir do |tmp|
          run %W(#{tmp} --dry-run)
          writer.write('12345')
          File.exists?("#{tmp}/#{filename}").should == false
        end
      end
    end

    context 'dry run and quiet' do
      it 'writes nothing to standard out' do
        tmpdir do |tmp|
          run %W(#{tmp} --dry-run --quiet)
          $stdout.should_not_receive(:print)
          writer.write('12345')
        end
      end

      it 'writes nothing to its file' do
        tmpdir do |tmp|
          run %W(#{tmp} --dry-run --quiet)
          writer.write('12345')
          File.exists?("#{tmp}/#{filename}").should == false
        end
      end
    end

    context 'normal run' do
      it 'writes nothing to standard out' do
        tmpdir do |tmp|
          run %W(#{tmp} --no-dry-run)
          $stdout.should_not_receive(:print)
          writer.write('12345')
        end
      end

      it 'writes to its file' do
        tmpdir do |tmp|
          run %W(#{tmp} --no-dry-run)
          writer.write('12345')
          File.size("#{tmp}/#{filename}").should == 5
        end
      end

      it 'creates the file path leading up to the document' do
        tmpdir do |tmp|
          run tmp
          writer.stub(:document_name).and_return('foo_dir/foo_file')
          writer.write('12345')
          File.directory?("#{tmp}/foo_dir").should == true
        end
      end
    end
  end
end
