require 'minitest/autorun'
require 'vcr'
require 'byebug'
require "minitest-vcr"
require "webmock"

Dir["./lib/**/*.rb"].each { |f| require f }

VCR.configure do |config|
  config.cassette_library_dir = 'test/cassettes'
  config.hook_into :webmock
  config.ignore_localhost = true
  config.allow_http_connections_when_no_cassette = false
  config.default_cassette_options = { record: :new_episodes }
end

MinitestVcr::Spec.configure!
