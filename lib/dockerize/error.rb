# coding: utf-8

module Dockerize
  module Error
    # Invalid Config Errors
    InvalidConfig = Class.new(StandardError)
    NonexistentProjectDirectory = Class.new(InvalidConfig)
    InvalidProjectDirectory = Class.new(InvalidConfig)

    # Argument Errors
    MissingRequiredArgument = Class.new(ArgumentError)
  end
end
