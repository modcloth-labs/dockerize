# coding: utf-8

require 'yaml'
require 'ostruct'
require 'dockerize/document_writer'

module Dockerize
  class DocumentWriterFromTemplate < Dockerize::DocumentWriter
    attr_reader :raw_content

    def initialize(contents_or_file)
      if File.exists?(contents_or_file)
        @raw_content = File.read(contents_or_file)
      else
        @raw_content = contents_or_file
      end
    end

    def yaml_metadata
      @yaml_header ||= yaml_documents[:metadata]
    end

    def yaml_content
      @yaml_content ||= yaml_documents[:content]
    end

    def parsed_erb
      @parsed_erb ||= parse_erb(yaml_content, template_vars)
    end

    def document_name
      yaml_metadata['filename']
    end

    def write
      super(parsed_erb)
    end

    private

    def template_vars
      Dockerize::Config.opts.merge(yaml_metadata)
    end

    def parse_erb(raw, hash)
      ERB.new(raw, 0, '%<>>-').result(
        OpenStruct.new(hash).instance_eval { binding }
      )
    end

    def yaml_documents
      @stream ||= YAML.load_documents(raw_content)
      @yaml_documents ||= {
        metadata: @stream[0],
        content: @stream[1].values[0],
      }
    end
  end
end
