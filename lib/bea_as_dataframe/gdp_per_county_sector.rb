require 'polars-df'
require 'httparty'
require 'csv'
require 'zip'
require 'tempfile'

class BeaAsDataframe
  class GdpPerCountySector
    include ::HTTParty

    def initialize(options={})
      @api_key = options[:api_key] || BeaAsDataframe.api_key
      @tmp_dir = options[:tmp_dir] || BeaAsDataframe.tmp_dir || '/tmp'
    end

    def fetch()
      url = 'https://apps.bea.gov/regional/zip/CAGDP9.zip'
      my_file = File.join(@tmp_dir, 'CAGDP9.zip')
      all_areas_fn = nil

      resp = HTTParty.get(url)
      exit if resp.code == 404

      Tempfile.create(['CAGDP9','.zip'], @tmp_dir, mode: File::RDWR, binmode: true) do |fn_a|
        fn_a.write resp.parsed_response
        fn_a.rewind

        Zip::File.open(fn_a.path) do |z|
          z.each do |f|
            next if (f.name =~ /ALL_AREAS/).nil?
            content = f.get_input_stream.read.gsub(/^\s*/,'')

            Tempfile.create(['gdp_per_cnty_sector', '.csv'], @tmp_dir, mode: File::RDWR, binmode: true) do |fn|
              fnp = fn.path 
              fn.write content
              fn.rewind

              d_converter = proc {|field| field == '(D)' || field == '(NA)' ? 0 : field }
              CSV::Converters[:d] = d_converter

              dta = CSV.parse(File.read(fnp).encode("utf-8", "binary", :undef => :replace), 
                headers:true, converters: [:numeric, :d]).select{|r| r['GeoFIPS'].is_a?(Numeric) }

              keys = dta.first.headers
              vals = dta.map{|r| r.to_h.values }.transpose

              tmp_df = {}; (0..(keys.length-1)).to_a.each{|i| tmp_df[keys[i]] = vals[i] }
              tmp_df = Polars::DataFrame.new(tmp_df)

              return tmp_df
            end                     
          end
        end
      end   
    end
  end
end