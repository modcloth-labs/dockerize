# coding: utf-8
# rubocop:disable MethodLength, SymbolName

require 'trollop'

module Dockerize
  class Config
    class << self
      attr_reader :project_dir

      def quiet?
        opts[:quiet]
      end

      def dry_run?
        opts[:'dry-run']
      end

      def parse(args)
        @opts = Trollop.options(args) do
          # -q/--quiet
          opt :quiet,
              'Silence output',
              type: :flag,
              short: 'q',
              default: false

          # -d/--dry-run
          opt :'dry-run',
              'Dry run, do not write any files',
              type: :flag,
              short: 'd',
              default: false
        end
        self.project_dir = args[0]
      end

      def project_dir=(dir)
        expanded_dir = File.expand_path(dir)

        if !File.exists?(expanded_dir)
          fail Dockerize::Error::NonexistentProjectDirectory,
               "Project directory '#{expanded_dir}' does not exist"
        elsif !File.directory?(expanded_dir)
          fail Dockerize::Error::InvalidProjectDirectory,
               "Project directory '#{expanded_dir}' is not a directory"
        else
          @project_dir = expanded_dir
        end
      end

      private

      attr_reader :opts
    end
  end
end
