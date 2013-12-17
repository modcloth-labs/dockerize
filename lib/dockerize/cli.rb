# coding: utf-8

require 'dockerize/error'

module Dockerize
  module Cli
    class << self
      attr_reader :args

      def run(argv = [])
        @args = argv
        ensure_project_dir
      end

      private

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
