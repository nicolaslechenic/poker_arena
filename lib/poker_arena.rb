require 'pry'
require 'bcrypt'
require 'mongoid'
require 'sinatra'
require 'sinatra/json'
require 'sinatra/namespace'

%w[
  card combo dealer deck
  hand player score table
].each do |file|
  require_relative "poker_arena/#{file}"
end

Mongoid.load!('./lib/config/mongoid.yml', :development)

namespace '/api' do
  helpers do
    def base_url
      @base_url ||=
        "#{request.env['rack.url_scheme']}://{request.env['HTTP_HOST']}"
    end

    def json_params
      JSON.parse(request.body.read)
    rescue StandardError
      halt 400, { message: 'Invalid JSON' }.to_json
    end
  end

  get '/players' do
    players = PokerArena::Player.all
    json(players: players)
  end

  post '/players' do
    player = PokerArena::Player.create_with_password(json_params)

    status 201 if player.save
  end
end
