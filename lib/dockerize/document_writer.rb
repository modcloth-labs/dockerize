# coding: utf-8

require 'fileutils'

module Dockerize
  class DocumentWriter
    # i/o stream
    # dry run options to print to standard out instead of writing to file
    # force to replace file if it already exists
    # printing informative output
    # read, write
    # filename
    # template location
    # write to file, stdout, nil

    # def should_backup?

    # end

    def write(contents, stream = $out)
      ensure_containing_dir
      _do_backup if should_backup?
      _do_write(contents, stream) if should_write?
    end

    def output_target
      "#{Dockerize::Config.project_dir}/#{document_name}"
    end

    private

    def should_backup?
      Dockerize::Config.backup? && preexisting_file?
    end

    def should_write?
      Dockerize::Config.force? || !preexisting_file?
    end

    def preexisting_file?
      File.exists?(output_target)
    end

    def ensure_containing_dir(target = output_target)
      FileUtils.mkdir_p(File.dirname(target))
    end

    def _do_write(contents, stream = $out)
      stream = File.open(output_target, 'w') unless Dockerize::Config.dry_run?
      stream.print contents
    ensure
      stream.close unless stream == $out
    end

    def _do_backup
      FileUtils.cp(output_target, "#{output_target}.bak")
    end

    def document_name
      fail Dockerize::Error::DocumentNameNotSpecified,
           "Document name not specified for class #{self.class.name}"
    end
  end
end
