# coding: utf-8

module Dockerize
  class Config
    class << self
      attr_reader :project_dir

      def project_dir=(dir)
        if !File.exists?(dir)
          fail Dockerize::Error::NonexistentProjectDirectory,
               "Project directory '#{dir}' does not exist"
        elsif !File.directory?(dir)
          fail Dockerize::Error::InvalidProjectDirectory,
               "Project directory '#{dir}' is not a directory"
        else
          @project_dir = dir
        end
      end
    end
  end
end
