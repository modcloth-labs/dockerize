# coding: utf-8

require 'ostruct'
require 'erb'

module Dockerize
  class TemplateParser
    attr_reader :raw_text
    attr_reader :metadata

    def initialize(contents)
      @raw_text = contents
      @metadata = []
    end

    def document_name
      metadata[:filename]
    end

    def executable?
      metadata[:executable] == true ? true : false
    end

    def write_with(writer)
      text = parsed_erb
      writer.document_name = document_name
      writer.write(text, executable?)
    end

    def parsed_erb
      return @parsed_erb if @parsed_erb
      begin
        @parsed_erb = parse_erb(raw_text, config_vars)
      rescue SyntaxError
        @parsed_erb = nil
      end
    end

    private

    def config_vars
      Dockerize::Config.opts
    end

    def parse_erb(raw, hash)
      os = OpenStruct.new(hash)
      os_before = os.clone
      result = ERB.new(raw, nil, '%<>>-').result(
        os.instance_eval { binding }
      )
      @metadata = hash_diff(os, os_before)
      result
    end

    def hash_diff(os1, os2)
      h1 = os1.marshal_dump
      h2 = os2.marshal_dump
      h1.dup.delete_if { |k, v| h2[k] == v }.merge!(
        h2.dup.delete_if { |k, v| h1.key?(k) }
      )
    end
  end
end
