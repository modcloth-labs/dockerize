# coding: utf-8

require 'dockerize/document_writer'
require 'fileutils'

describe Dockerize::DocumentWriter do
  let(:writer) { described_class.new }

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

  describe 'determining if the file should be written' do
    let(:filename) { 'foo_file' }
    let(:backup_filename) { 'foo_file.bak' }
    let(:content) { '12345' }

    before(:each) { writer.stub(:document_name).and_return(filename) }

    context 'without force' do
      context 'the file already exists' do
        it 'does not modify the existing file' do
          tmpdir do |tmp|
            file_path = "#{tmp}/#{filename}"
            FileUtils.touch(file_path)
            run "#{tmp} --no-force"
            expect { writer.write(content) }.to_not change {
              File::Stat.new(file_path).inspect
            }
          end
        end

        it 'marks the file as ignored' do
          tmpdir do |tmp|
            file_path = "#{tmp}/#{filename}"
            FileUtils.touch(file_path)
            run "#{tmp} --no-force"
            writer.should_receive(:inform_of_write).with(
              Dockerize::DocumentWriter::IGNORE_WORD
            )
            writer.write(content)
          end
        end
      end

      context 'the file does not already exist' do
        it 'creates the file' do
          tmpdir do |tmp|
            file_path = "#{tmp}/#{filename}"
            run "#{tmp} --no-force"
            expect { writer.write(content) }.to change {
              File.exists?(file_path)
            }
          end
        end

        it 'marks the file as created' do
          tmpdir do |tmp|
            run "#{tmp} --no-force"
            writer.should_receive(:inform_of_write).with(
              Dockerize::DocumentWriter::CREATE_WORD
            )
            writer.write(content)
          end
        end
      end
    end

    context 'with force' do
      context 'the file already exists' do
        it 'modifies the file' do
          tmpdir do |tmp|
            file_path = "#{tmp}/#{filename}"
            run "#{tmp} --force"
            FileUtils.touch(file_path)
            expect { writer.write(content) }.to change {
              File::Stat.new(file_path).inspect
            }
          end
        end

        it 'marks the file as replaced' do
          tmpdir do |tmp|
            run "#{tmp} --force"
            FileUtils.touch("#{tmp}/#{filename}")
            writer.should_receive(:inform_of_write).with(
              Dockerize::DocumentWriter::REPLACE_WORD
            )
            writer.write(content)
          end
        end

        context 'backup option is specified' do
          it 'creates a backup file' do
            tmpdir do |tmp|
              file_path = "#{tmp}/#{filename}"
              backup_path = "#{tmp}/#{backup_filename}"
              run "#{tmp} --force --backup"
              FileUtils.touch(file_path)
              expect { writer.write(content) }.to change {
                File.exists?(backup_path)
              }
            end
          end
        end

        context '--no-backup option is specified' do
          it 'does not create create a backup file' do
            tmpdir do |tmp|
              file_path = "#{tmp}/#{filename}"
              backup_path = "#{tmp}/#{backup_filename}"
              run "#{tmp} --force --no-backup"
              FileUtils.touch(file_path)
              expect { writer.write(content) }.to_not change {
                File.exists?(backup_path)
              }
            end
          end
        end
      end

      context 'the file does not already exist' do
        it 'creates the file' do
          tmpdir do |tmp|
            file_path = "#{tmp}/#{filename}"
            run "#{tmp} --force"
            expect { writer.write(content) }.to change {
              File.exists?(file_path)
            }
          end
        end

        it 'marks the file as created' do
          tmpdir do |tmp|
            run "#{tmp} --force"
            writer.should_receive(:inform_of_write).with(
              Dockerize::DocumentWriter::CREATE_WORD
            )
            writer.write(content)
          end
        end
      end
    end
  end

  describe 'writing' do
    let(:filename) { 'foo_file' }
    let(:writer) { described_class.new(filename) }

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

    context 'invalid content is provided' do
      it 'should not create the file' do
        tmpdir do |tmp|
          run tmp
          writer.stub(:document_name).and_return('foo_file')
          expect { writer.write(nil) }.to_not change {
            File.exists?("#{tmp}/foo_file")
          }
        end
      end

      it 'should print useful output mesages' do
        tmpdir do |tmp|
          run tmp
          writer.stub(:document_name).and_return('foo_file')
          writer.should_receive(:inform_of_write).with(
            writer.send(:invalid_word)
          )
          writer.write(nil)
        end

      end
    end
  end
end
