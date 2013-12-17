# coding: utf-8

module Dockerize
  class Config
    class << self
      attr_reader :project_dir

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
    end
  end
end
