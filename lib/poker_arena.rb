require 'bcrypt'
require 'pry'
require 'sinatra'
require 'sinatra/json'
require 'sinatra/namespace'
require_relative '../configuration/initializers/sequel'

PokerArena::SequelDb.connect

Dir['./lib/models/*.rb'].each { |file| require file }
Dir['./lib/controllers/*_controller.rb'].each { |file| require file }

module PokerArena
  class Launcher < Sinatra::Base
    register Sinatra::Namespace
    use PlayersController
    use TablesController
  end
end
