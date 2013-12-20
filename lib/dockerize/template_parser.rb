# coding: utf-8

require 'yaml'
require 'ostruct'

module Dockerize
  class TemplateParser
    attr_reader :raw_text

    def initialize(contents)
      @raw_text = contents
    end

    def yaml_metadata
      @yaml_header ||= yaml_documents[:metadata]
    end

    def yaml_content
      @yaml_content ||= yaml_documents[:content]
    end

    def parsed_erb
      @parsed_erb ||= begin
                        parse_erb(yaml_content, template_vars)
                      rescue Psych::SyntaxError, SyntaxError
                        nil
                      end
    end

    def document_name
      yaml_metadata['filename']
    end

    def executable?
      yaml_metadata['executable'] == true ? true : false
    end

    def write_with(writer)
      writer.document_name = document_name
      writer.write(parsed_erb, executable?)
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
      @stream ||= YAML.load_documents(raw_text)
      @yaml_documents ||= {
        metadata: @stream[0],
        content: @stream[1].values[0],
      }
    end
  end
end
