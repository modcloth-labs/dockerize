# coding: utf-8

module Dockerize
    class << self
      attr_reader :args

      def run(argv = [])
        @args = argv
        ensure_project_dir
        set_out_stream
      end

      private

      def set_out_stream
        $out = $stdout
        $out = File.open('/dev/null', 'w') if Dockerize::Config.quiet?
      end
      def ensure_project_dir
        if args.count < 1
          fail Dockerize::Error::MissingRequiredArgument,
               'You must specify a project directory to dockerize'
        else
          Dockerize::Config.parse(args)
        end
      end
    end
  end
end
