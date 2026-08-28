# frozen_string_literal: true

require_relative "bea_as_dataframe/version"
require_relative "bea_as_dataframe/gdp_per_county_sector"

class BeaAsDataframe
  class Error < StandardError; end
  class HTTPError < Error; end

  def self.configure
    yield self
    true
  end

  class << self
    attr_accessor :api_key, :tmp_dir
  end
end
