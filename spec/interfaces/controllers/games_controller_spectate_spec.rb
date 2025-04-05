# frozen_string_literal: true

require 'spec_helper'
require 'rack/test'

RSpec.describe 'Spectator API', type: :controller do
  include Rack::Test::Methods

  let(:players_repository) { PokerArena::Infrastructure::Repositories::PlayersRepository.new }
  let(:tables_repository) { PokerArena::Infrastructure::Repositories::TablesRepository.new(nil, true) }
  let(:table) { PokerArena::Domain::Entities::Table.new(tables_repository: tables_repository) }
  let(:player1) { PokerArena::Domain::Entities::Player.new(pseudo: 'Player1') }
  let(:player2) { PokerArena::Domain::Entities::Player.new(pseudo: 'Player2') }

  before do
    players_repository.persist(player1)
    players_repository.persist(player2)
    tables_repository.persist(table)
    table.seat_in(player1)
    table.seat_in(player2)
  end

  describe 'GET /api/tables/:name/spectate' do
    context 'when no game is in progress' do
      it 'returns a waiting state' do
        get "/api/tables/#{table.name}/spectate"

        expect(last_response.status).to eq(200)
        expect(JSON.parse(last_response.body)['state']).to eq('waiting')
      end
    end

    context 'when a game is in progress' do
      before do
        post "/api/tables/#{table.name}/start", { token: player1.token }.to_json,
             { 'CONTENT_TYPE' => 'application/json' }
      end

      it 'returns the game state without player cards' do
        get "/api/tables/#{table.name}/spectate"

        expect(last_response.status).to eq(200)

        response_body = JSON.parse(last_response.body)
        expect(response_body['state']).to eq('active')
        expect(response_body['game']['status']).to eq('preflop')
        expect(response_body['game']['pot']).to eq(table.small_blind + table.big_blind)
        expect(response_body['game']['players'].count).to eq(2)

        response_body['game']['players'].each do |player_data|
          expect(player_data).not_to have_key('cards')
        end
      end
    end
  end
end
