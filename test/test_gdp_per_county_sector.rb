require "test_helper"

class TestGdpPerCountySector < Minitest::Test
  def setup
    @tmp_dir = Dir.mktmpdir
    BeaAsDataframe.configure do |config|
      config.tmp_dir = @tmp_dir
    end
    @fetcher = BeaAsDataframe::GdpPerCountySector.new
  end

  def teardown
    FileUtils.remove_entry(@tmp_dir) if @tmp_dir && File.exist?(@tmp_dir)
  end

  def test_fetch_success
    # Read the fixture ZIP file
    fixture_zip = File.read(File.join(__dir__, 'fixtures', 'CAGDP9.zip'), mode: 'rb')
    
    # Mock the HTTP request to return our fixture
    stub_request(:get, "https://apps.bea.gov/regional/zip/CAGDP9.zip")
      .to_return(status: 200, body: fixture_zip, headers: {})

    # Fetch the data
    df = @fetcher.fetch

    # Verify we got a DataFrame back
    refute_nil df
    assert_respond_to df, :shape
    
    # Verify the DataFrame has the expected structure
    shape = df.shape
    assert_equal 4, shape[0], "Expected 4 rows with numeric GeoFIPS"
    assert shape[1] > 0, "Expected at least one column"
  end

  def test_fetch_handles_http_404
    # Mock a 404 response
    stub_request(:get, "https://apps.bea.gov/regional/zip/CAGDP9.zip")
      .to_return(status: 404, body: "Not Found", headers: {})

    # Verify that fetch raises an HTTPError instead of calling exit
    error = assert_raises(BeaAsDataframe::HTTPError) do
      @fetcher.fetch
    end

    assert_match(/HTTP 404/, error.message)
  end

  def test_fetch_handles_http_500
    # Mock a 500 response
    stub_request(:get, "https://apps.bea.gov/regional/zip/CAGDP9.zip")
      .to_return(status: 500, body: "Internal Server Error", headers: {})

    # Verify that fetch raises an HTTPError
    error = assert_raises(BeaAsDataframe::HTTPError) do
      @fetcher.fetch
    end

    assert_match(/HTTP 500/, error.message)
  end

  def test_configuration_with_tmp_dir
    custom_tmp = Dir.mktmpdir
    begin
      fetcher = BeaAsDataframe::GdpPerCountySector.new(tmp_dir: custom_tmp)
      
      # Verify the fetcher is using the custom tmp_dir
      assert_equal custom_tmp, fetcher.instance_variable_get(:@tmp_dir)
    ensure
      FileUtils.remove_entry(custom_tmp) if custom_tmp && File.exist?(custom_tmp)
    end
  end
end
