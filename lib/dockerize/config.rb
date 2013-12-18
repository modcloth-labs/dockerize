# coding: utf-8
# rubocop:disable MethodLength

require 'trollop'

module Dockerize
  class Config
    class << self
      attr_reader :project_dir

      def parse(args)
        config = self

        Trollop.options(args) do
          # -q/--quiet
          opt :quiet,
              'Silence output',
              type: :flag,
              short: 'q',
              default: false

          # -d/--dry-run
          opt :dry_run,
              'Dry run, do not write any files',
              type: :flag,
              short: 'd',
              default: false

          # -f/--force
          opt :force,
              'Force existing files to be overwritten',
              type: :flag,
              sort: 'f',
              default: false

          # -b/--backup
          opt :backup,
              'Creates .bak version of files before overwriting them',
              type: :flag,
              sort: 'b',
              default: true

          config.send(:opts=, parse(args))
          config.send(:generate_accessor_methods, self)
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

      attr_accessor :opts

      def klass
        @klass ||= class << self ; self ; end
      end

      def add_method(name, &block)
        klass.send(:define_method, name.to_sym, &block)
      end

      def generate_accessor_methods(parser)
        _for_flags(parser.specs.select do |k, v|
          Trollop::Parser::FLAG_TYPES.include?(v[:type])
        end)
      end

      #################################################################
      # method generation methods for different types of command line #
      # arguments                                                     #
      #################################################################

      def _for_flags(args = {})
        args.map do |k, _|
          add_method("#{k}?") do
            @opts[k]
          end
        end
      end
    end
  end
end
