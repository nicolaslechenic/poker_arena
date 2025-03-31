# frozen_string_literal: true

require 'bcrypt'
require 'pry'
require 'sinatra'
require 'sinatra/json'
require './lib/serializers/application_serializer'
require './lib/models/combo'

# Load all files in the lib directory
Dir['./lib/models/**/*.rb'].each { |file| require file }
Dir['./lib/serializers/*.rb'].each { |file| require file }
Dir['./lib/repositories/*.rb'].each { |file| require file }
Dir['./lib/services/*.rb'].each { |file| require file }
Dir['./lib/presenters/*.rb'].each { |file| require file }
Dir['./lib/use_cases/*.rb'].each { |file| require file }
Dir['./lib/controllers/*_controller.rb'].each { |file| require file }

module PokerArena
  class Launcher < Sinatra::Base
    players_repository  = PlayersRepository.new
    tables_repository   = TablesRepository.new

    # Initialize predefined tables
    UseCases::InitializeTables.new(tables_repository).call

    use(PlayersController, players_repository: players_repository)
    use(
      TablesController,
      tables_repository: tables_repository,
      players_repository: players_repository
    )
    use(
      GamesController,
      tables_repository: tables_repository,
      players_repository: players_repository
    )
  end
end
