require 'polars-df'
require 'httparty'
require 'csv'

class BeaAsDataframe
  class GdpPerCountySector
    include ::HTTParty
    attr_reader :tag

    def initialize(series, options={})
      @api_key = options[:api_key] || BeaAsDataframe.api_key
      @tag = series
    end

    def fetch(start: nil, fin: nil, interval: '1d')
      url = 'https://apps.bea.gov/regional/zip/CAGDP9.zip'
      my_file = File.join(Settings.tmp_dir, 'CAGDP9.zip')
      all_areas_fn = nil

      begin
        resp = HTTParty.get(url)
        exit if resp.code == 404
        (fn = File.open(my_file, 'wb')).write(resp.parsed_response) and fn.close
      rescue
        sleep 300.0
        retry
      end

      Zip::File.open(my_file) { |z|
        z.each do |f|
          next if (f.name =~ /ALL_AREAS/).nil?
          all_areas_fn = File.join(Settings.tmp_dir, f.name)
          z.extract(f, all_areas_fn)
        end
      }

      all_county_fips = Geo::County.all.map(&:id)
      all_state_fips = Geo::State.all.map(&:fips)
      repdtes = all_repdtes
      # rowcount = 0

      fnp = (fn = Tempfile.new(['gdp_per_cnty_sector', '.csv'], Settings.tmp_dir, {mode: File::RDWR})).path
      File.readlines(all_areas_fn)[1..-1].each do |lin|
        begin
          ln = CSV.parse(lin.strip)[0]
          next if ln.nil? || ln.length < 3

          grouptype = nil
          groupname = nil
          yr = 2001
          first_col = 8
          dat = {}

          ln[0] = ln[0].to_i
          if ln[0].zero?
            grouptype = 'all' and groupname = 1
          elsif (ln[0] % 1000).zero?
            grouptype = 'stalp' and groupname = ln[0]/1000
            next unless groupname.in?(all_state_fips)
          else
            grouptype = 'county' and groupname = ln[0]
            next unless groupname.in?(all_county_fips)
          end

          next if ','.in?(ln[5]) || '.'.in?(ln[5])
          next unless ln[5].length <= 5
          sector = ln[5]

          (first_col..ln.length-1).each do |i|
            repdte = "#{yr+i-first_col}-12-31".to_date
            value = Float(ln[i], exception: false)
            next if value.nil?

            dat[repdte] = value
          end

          n = dat.keys.length
          next if n < 4

          dt = dat.keys.min
          dt_min = dat.keys.min
          min_val = dat[dt_min].to_f
          dt_max = dat.keys.max
          max_val = dat[dt_max].to_f

          x = ::GSL::Vector[n]
          y = ::GSL::Vector[n]
          dat.keys.each_with_index { |dt, i| x[i] = dt.to_time.to_f; y[i] = dat[dt].to_f }
          i = ::GSL::Interp.alloc("cspline", n)
          i.init(x,y)

      rescue
      end
    end
  end
end