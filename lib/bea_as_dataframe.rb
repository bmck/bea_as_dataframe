# frozen_string_literal: true

require_relative "bea_as_dataframe/version"

class BeaAsDataframe
  def self.configure
    yield self
    true
  end

  class << self
    attr_accessor :api_key
  end
  
  class Error < StandardError; end
  # Your code goes here...
end
