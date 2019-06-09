require 'bcrypt'
require 'pry'
require 'sinatra'
require 'sinatra/json'
require 'sinatra/namespace'
require_relative '../configuration/initializers/sequel.rb'

Dir['./lib/models/*.rb'].each { |file| require file }
Dir['./lib/controllers/*_controller.rb'].each { |file| require file }

module PokerArena
  class Endpoints < Sinatra::Base
    register Sinatra::Namespace
    use TablesController
  end
end
