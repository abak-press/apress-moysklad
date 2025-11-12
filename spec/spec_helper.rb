require 'rubygems'
require 'bundler/setup'

require 'simplecov'

SimpleCov.start do
  minimum_coverage 95
end

require 'apress/moysklad'

require 'rspec'
require 'rspec/its'
require 'rspec/collection_matchers'

require 'timecop'
require 'webmock/rspec'
require 'vcr'

require 'pry-byebug'

VCR.configure do |config|
  config.cassette_library_dir = 'spec/fixtures/cassettes'
  config.hook_into :webmock

  config.before_record do |i|
    i.response.body.force_encoding('UTF-8')
  end

  config.filter_sensitive_data('<TOKEN>') do |interaction|
    auth_header = interaction.request.headers['Authorization']
    if auth_header && (match = auth_header.first.match(/^Basic\s+([^,\s]+)/))
      match.captures.first
    end
  end
end
