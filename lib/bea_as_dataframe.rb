# frozen_string_literal: true

require_relative "bea_as_dataframe/version"
require_relative "bea_as_dataframe/gdp_per_county_sector"

class BeaAsDataframe
  def self.configure
    yield self
    true
  end

  class << self
    attr_accessor :api_key, :tmp_dir
  end

  # class Error < StandardError; end
  # Your code goes here...
end
