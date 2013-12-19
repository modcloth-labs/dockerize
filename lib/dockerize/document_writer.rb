# coding: utf-8

require 'fileutils'

module Dockerize
  class DocumentWriter
    CREATE_WORD = 'created '.green
    REPLACE_WORD = 'replaced '.red
    IGNORE_WORD = 'ignored '.yellow

    # printing informative output
    # read, write
    # template location

    def write(contents, stream = $out)
      ensure_containing_dir
      do_backup! if should_backup?
      inform_of_write(create_word)
      do_write!(contents, stream) if should_write?
    end

    def output_target
      "#{Dockerize::Config.project_dir}/#{document_name}"
    end

    def create_word
      if !should_write?
        IGNORE_WORD
      elsif preexisting_file?
        REPLACE_WORD
      else
        CREATE_WORD
      end
    end

    def inform_of_write(type)
      $out.puts '     ' << type <<  document_name
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

    def do_write!(contents, stream = $out)
      stream = File.open(output_target, 'w') unless Dockerize::Config.dry_run?
      stream.print contents
    ensure
      stream.close unless stream == $out
    end

    def do_backup!
      FileUtils.cp(output_target, "#{output_target}.bak")
    end

    def document_name
      fail Dockerize::Error::DocumentNameNotSpecified,
           "Document name not specified for class #{self.class.name}"
    end
  end
end
