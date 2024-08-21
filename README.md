# BeaAsDataframe

Up to date remote economic data access for ruby, using Polars dataframes. 

This package will fetch economic and financial information from the Bureau of Economic Analysis, and return the results as a Polars Dataframe.  For some operations, you may need an API key that can be fetched from the BEA website at https://apps.bea.gov/API/signup/ .

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'bea_as_dataframe'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install bea_as_dataframe

## Configuration

Some data sources will require the specification of an API key.  These keys should be provided as part of a configuration file, e.g., config/bea_as_dataframe.rb

Other operations (those in BeaAsDataframe::GdpPerCountySector) will require the specification of a directory for temporarily storing datafiles.  See the following initialization snippet to providing that customization.

```ruby
BeaAsDataframe::Client.configure do |config|
  config.api_key = '1234567890ABCDEF'
    # OR
  config.api_key = File.read(File.join('','home', 'user', '.bea_api_key.txt'))

  config.tmp_dir = File.join('', 'tmp')
end
```    

## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/bea_as_dataframe. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/[USERNAME]/bea_as_dataframe/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the BeaAsDataframe project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/bea_as_dataframe/blob/main/CODE_OF_CONDUCT.md).
