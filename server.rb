require 'pry'
require 'sinatra'
require 'sinatra/json'
require 'sinatra/namespace'
require './lib/poker_arena'

namespace '/api' do
  # @param user
  get '/pokerarena' do
    res = PokerArena.run
    json(message: res)
  end
end
