require 'pry'
require 'bcrypt'
require 'mongoid'
require 'sinatra'
require 'sinatra/json'
require 'sinatra/namespace'

%w[
  bankroll board card combo dealer deck
  hand player pot score table
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

    halt 422, { message: 'Invalid JSON' }.to_json unless player.save
    bankroll = PokerArena::Bankroll.new(player_id: player.id)

    halt 422, { message: 'Bankroll error...' }.to_json unless bankroll.save
    status 200
  end

  get '/tables' do
    tables =
      PokerArena::Table.instances.map do |table|
        {
          players: table.players.count,
          label: table.label
        }
      end

    json(tables: tables)
  end

  post '/tables' do
    label = json_params['label']
    deck = PokerArena::Deck.new
    dealer = PokerArena::Dealer.new(deck: deck)
    board = PokerArena::Board.new
    pot = PokerArena::Pot.new

    PokerArena::Table.new(
      dealer: dealer,
      label: label,
      board: board,
      pot: pot
    )
  end
end
