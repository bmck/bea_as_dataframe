# frozen_string_literal: true

require 'set'
require 'bundler/setup'
require_relative '../lib/bea_as_dataframe'

failures = []
failures << 'version' if BeaAsDataframe::VERSION.to_s.empty?
failures << 'configure' unless BeaAsDataframe.respond_to?(:configure)
gdp = BeaAsDataframe::GdpPerCountySector.new
failures << 'instantiate' unless gdp.is_a?(BeaAsDataframe::GdpPerCountySector)
failures << 'fetch' unless gdp.respond_to?(:fetch)

if failures.empty?
  puts 'test_bea: ok'
else
  abort "test_bea failed: #{failures.join(', ')}"
end
