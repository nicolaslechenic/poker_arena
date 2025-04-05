# frozen_string_literal: true

require 'bcrypt'
require 'pry'
require 'sinatra'
require 'sinatra/json'
require './lib/interfaces/serializers/application_serializer'
require './lib/domain/entities/combo'

Dir['./lib/domain/entities/**/*.rb'].each { |file| require file }
Dir['./lib/domain/services/**/*.rb'].each { |file| require file }
Dir['./lib/infrastructure/repositories/*.rb'].each { |file| require file }
Dir['./lib/infrastructure/persistence/*.rb'].each { |file| require file }
Dir['./lib/interfaces/serializers/*.rb'].each { |file| require file }
Dir['./lib/interfaces/presenters/*.rb'].each { |file| require file }
Dir['./lib/interfaces/controllers/*_controller.rb'].each { |file| require file }
Dir['./lib/application/use_cases/*.rb'].each { |file| require file }

module PokerArena
  class Launcher < Sinatra::Base
    players_repository  = Infrastructure::Repositories::PlayersRepository.new
    tables_repository   = Infrastructure::Repositories::TablesRepository.new

    Application::UseCases::InitializeTables.new(tables_repository).call

    use(Interfaces::Controllers::PlayersController, players_repository: players_repository)
    use(
      Interfaces::Controllers::TablesController,
      tables_repository: tables_repository,
      players_repository: players_repository
    )
    use(
      Interfaces::Controllers::GamesController,
      tables_repository: tables_repository,
      players_repository: players_repository
    )
  end
end
