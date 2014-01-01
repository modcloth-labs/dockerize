# coding: utf-8

require 'dockerize/template_parser'
require 'dockerize/document_writer'

module Dockerize
  class Cli
    class << self
      attr_reader :args

      def run(argv = [])
        @args = argv
        ensure_project_dir
        parse_args
        set_out_stream
        handle_templates
      end

      private

      attr_writer :args

      def handle_templates
        all_templates.map do |template|
          Dockerize::TemplateParser.new(File.read(template))
            .write_with Dockerize::DocumentWriter.new
        end
      end

      def all_templates
        Dir["#{Dockerize::Config.template_dir}/**/*.erb"]
      end

      def set_out_stream
        $out = $stdout
        $out = File.open('/dev/null', 'w') if Dockerize::Config.quiet?
      end

      def parse_args
        Dockerize::Config.parse(args)
      end

      def ensure_project_dir
        if args.count < 1 && !%w(-h --help).include?(args[0])
          fail Dockerize::Error::MissingRequiredArgument,
               'You must specify a project directory to dockerize'
        end
      end
    end
  end
end
