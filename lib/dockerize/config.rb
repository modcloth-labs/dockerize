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
              short: 'f',
              default: false

          # -b/--backup
          opt :backup,
              'Creates .bak version of files before overwriting them',
              type: :flag,
              short: 'b',
              default: true

          version "dockerize #{Dockerize::VERSION}"

          begin
            config.send(:opts=, parse(args))
          rescue Trollop::CommandlineError => e
            $stderr.puts "Error: #{e.message}."
            $stderr.puts 'Try --help for help.'
            exit 1
          rescue Trollop::HelpNeeded
            educate
            exit
          rescue Trollop::VersionNeeded
            $stderr.puts version
            exit
          end

          config.send(:generate_accessor_methods, self)
        end

        self.project_dir = args[0]
      end

      def project_dir=(dir)
        unless dir
          fail Dockerize::Error::UnspecifiedProjectDirectory,
               'You must specify a project directory'
        end

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
        parser.specs.map do |k, v|
          case v[:type]
          when *Trollop::Parser::FLAG_TYPES
            add_method("#{k}?") { @opts[k] }
          when :string
            add_method("#{k}") { @opts[k] }
          end
        end
      end
    end
  end
end
