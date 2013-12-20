# coding: utf-8

module Dockerize
  class Cli
    class << self
      attr_reader :args

      def run(argv = [])
        @args = argv
        ensure_project_dir
        parse_args
        set_out_stream
      end

      # read in a list of files in the templates dir
      # run all of them through FromTemplate
      # catch errors and try to make them useful
      # # including yaml parsing error, no document_name name found

      private

      attr_writer :args

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
