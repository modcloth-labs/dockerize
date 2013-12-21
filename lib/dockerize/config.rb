# coding: utf-8
# rubocop:disable MethodLength, ClassLength

require 'trollop'

module Dockerize
  class Config
    class << self
      attr_reader :project_dir
      attr_accessor :opts

      def parse(args)
        config = self

        Trollop.options(args) do
          # -q/--quiet
          opt :quiet, 'Silence output', type: :flag, short: 'q', default: false

          # -d/--dry-run
          opt :dry_run, 'Dry run, do not write any files',
              type: :flag,
              short: 'd',
              default: false

          # -f/--force
          opt :force, 'Force existing files to be overwritten',
              type: :flag,
              short: 'f',
              default: false

          # -b/--backup
          opt :backup, 'Creates .bak version of files before overwriting them',
              type: :flag,
              short: 'b',
              default: true

          # -r/--registry
          opt :registry, 'The Docker registry to use when writing files',
              type: :string,
              short: 'r',
              default: 'quay.io/modcloth'

          # -p/--project-name
          opt :project_name, 'The name of the current project',
              type: :string,
              short: 'p',
              default: nil

          # -t/--template-dir
          opt :template_dir,
              'The directory containing the templates to be written',
              type: :string,
              short: 't',
              default: "#{config.top}/templates"

          # -m/--maintainer
          opt :maintainer,
              'The default maintainer to use for any Dockerfiles written',
              type: :string,
              short: 'm',
              default: "#{ENV['USER']} <#{ENV['USER']}@example.com>"

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

          config.send(:opts)[:top] = config.top
          config.send(:generate_accessor_methods, self)
        end

        self.project_dir = args[0]
        set_project_name unless opts[:project_name]
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

      def set_project_name
        opts[:project_name] ||= File.basename(project_dir)
      end

      def top
        @top ||= Gem::Specification.find_by_name('dockerize').gem_dir
      end

      private

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
