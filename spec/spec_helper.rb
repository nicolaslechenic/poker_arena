# frozen_string_literal: true

require 'simplecov'
SimpleCov.start do
  add_filter '/spec/'
  add_group 'Controllers', 'lib/interfaces/web'
  add_group 'Models', 'lib/domain/entities'
  add_group 'Repositories', 'lib/infrastructure/repositories'
  add_group 'Serializers', 'lib/interfaces/serializers'
  add_group 'Services', 'lib/domain/services'
  add_group 'Use Cases', 'lib/application/use_cases'
end

require 'pry'
require 'yaml'
require 'poker_arena'

Dir['spec/support/*.rb'].each { |path| require "./#{path}" }

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups
end
