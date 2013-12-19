# coding: utf-8

module Dockerize
  module Error
    # Invalid Config Errors
    InvalidConfig = Class.new(StandardError)
    NonexistentProjectDirectory = Class.new(InvalidConfig)
    InvalidProjectDirectory = Class.new(InvalidConfig)
    UnspecifiedProjectDirectory = Class.new(InvalidConfig)

    # General Errors
    MissingRequiredArgument = Class.new(ArgumentError)
    DocumentNameNotSpecified = Class.new(NoMethodError)
  end
end
