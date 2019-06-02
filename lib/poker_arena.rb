require 'pry'
require 'bcrypt'
require 'mongoid'
require 'sinatra'
require 'sinatra/json'
require 'sinatra/namespace'

Mongoid.load!('./lib/config/mongoid.yml', :development)

Dir['./lib/poker_arena/*.rb'].each { |file| require file }

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

    halt 422, { message: 'Invalid JSON' }.to_json unless player.save

    status 200
  end

  get '/tables' do
    tables = PokerArena::Table.all

    json(tables: tables)
  end

  post '/tables' do
    name = json_params['name']

    PokerArena::Table.new(name: name)
  end
end
