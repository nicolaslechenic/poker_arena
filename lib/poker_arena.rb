require 'bcrypt'
require 'pry'
require 'sinatra'
require 'sinatra/json'
require './lib/serializers/application_serializer'

Dir['./lib/models/**/*.rb'].each { |file| require file }
Dir['./lib/serializers/*.rb'].each { |file| require file }
Dir['./lib/repositories/*.rb'].each { |file| require file }
Dir['./lib/controllers/*_controller.rb'].each { |file| require file }

module PokerArena
  class Launcher < Sinatra::Base
    players_repository  = PlayersRepository.new
    tables_repository   = TablesRepository.new

    use(PlayersController, players_repository: players_repository)
    use(
      TablesController,
      tables_repository: tables_repository,
      players_repository: players_repository
    )
  end
end
