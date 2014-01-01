# coding: utf-8
# rubocop:disable MethodLength, ClassLength, CyclomaticComplexity

require 'optparse'

module Dockerize
  class Config
    class << self
      attr_reader :project_dir
      attr_accessor :opts

      def parse(args)
        # defaults
        @opts = {
          quiet: false,
          dry_run: false,
          force: false,
          backup: true,
          registry: ENV['DOCKERIZE_REGISTRY'] || 'quay.io/modcloth',
          template_dir: ENV['DOCKERIZE_TEMPLATE_DIR'] || "#{top}/templates",
          maintainer: ENV['DOCKERIZE_MAINTAINER'] ||
            "#{ENV['USER']} <#{ENV['USER']}@example.com>",
          from: ENV['DOCKERIZE_FROM'] || 'ubuntu:12.04',
        }

        OptionParser.new do |opt|
          # -q/--quiet
          opt.on('-q', '--[no-]quiet', 'Silence output') do |q|
            opts[:quiet] = q
          end

          # -d/--dry-run
          opt.on(
            '-d', '--[no-]dry-run', 'Dry run, do not write any files'
          ) do |d|
            opts[:dry_run] = d
          end

          # -f/--force
          opt.on(
            '-f', '--[no-]force', 'Force existing files to be overwritten'
          ) { |f| opts[:force] = f }

          # -b/--backup
          opt.on(
            '-b',
            '--[no-]backup',
            'Creates .bak version of files before overwriting them',
          ) { |b| opts[:backup] = b }

          # -r/--registry
          opt.on(
            '-r REGISTRY',
            '--registry REGISTRY',
            'The Docker registry to use when writing files'
          ) { |r| opts[:registry] = r }

          # -t/--template-dir
          opt.on(
            '-t TEMPLATE_DIR',
            '--template-dir TEMPLATE_DIR',
            'The directory containing the templates to be written',
          ) { |t| opts[:template_dir] = t }

          # -m/--maintainer
          opt.on(
            '-m MAINTAINER',
            '--maintainer MAINTAINER',
            'The default MAINTAINER to use for any Dockerfiles written'
          ) { |m| opts[:maintainer] = m }

          # -F/--from
          opt.on(
            '-F FROM',
            '--from FROM',
            'The default base image to use for any Dockerfiles written'
          ) { |f| opts[:from] = f }

          # -h/--help
          opt.on_tail('-h', '--help', 'Display this message') do
            $stderr.puts opt.help
            exit
          end

          # -v/--version
          opt.on_tail('-v', '--version', 'Show version and exit') do
            $stderr.puts "dockerize #{Dockerize::VERSION}"
            exit
          end
        end.parse!(args)

        self.project_dir = args[0]
        set_project_name unless opts[:project_name]
        generate_accessor_methods
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

      def generate_accessor_methods
        opts.each do |k, v|
          case v
          when TrueClass, FalseClass
            add_method("#{k}?") { opts[k] }
          when String
            add_method("#{k}") { opts[k] }
          else
            fail OptionParser::InvalidOption, "Invalid option #{k}"
          end
        end
      end
    end
  end
end
