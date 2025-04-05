# frozen_string_literal: true

require 'spec_helper'
require 'rack/test'

RSpec.describe PokerArena::Interfaces::Controllers::GamesController, type: :controller do
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

  describe 'POST /api/tables/:name/start' do
    it 'starts a game successfully' do
      post "/api/tables/#{table.name}/start", { token: player1.token }.to_json, { 'CONTENT_TYPE' => 'application/json' }

      expect(last_response.status).to eq(200)
      expect(JSON.parse(last_response.body)['message']).to eq('Game started')

      expect(table.sets).not_to be_empty
      expect(table.sets.last.games).not_to be_empty
      expect(table.sets.last.games.last.status).to eq(:preflop)

      expect(player1.cards.count).to eq(2)
      expect(player2.cards.count).to eq(2)

      expect(table.pot).to eq(table.small_blind + table.big_blind)
    end

    it 'returns an error if not enough players' do
      table.seat_out(player2)

      post "/api/tables/#{table.name}/start", { token: player1.token }.to_json, { 'CONTENT_TYPE' => 'application/json' }

      response_body = JSON.parse(last_response.body)
      expect(response_body['error']).to eq('Not enough players to start a game')
    end
  end

  describe 'POST /api/tables/:name/action' do
    before do
      post "/api/tables/#{table.name}/start", { token: player1.token }.to_json, { 'CONTENT_TYPE' => 'application/json' }
    end

    it 'allows a valid action' do
      current_set = table.sets.last
      current_game = current_set.games.last

      first_to_act_pos = (current_set.button_position + 3) % table.players.count
      first_to_act = table.players[first_to_act_pos]

      post "/api/tables/#{table.name}/action", {
        token: first_to_act.token,
        action_type: 'call',
        value: table.big_blind
      }.to_json, { 'CONTENT_TYPE' => 'application/json' }

      expect(last_response.status).to eq(200)
      expect(JSON.parse(last_response.body)['message']).to eq('Action processed')

      expect(current_game.actions.count).to eq(3)
      expect(current_game.actions.last.type).to eq(:call)
      expect(current_game.actions.last.value).to eq(0)
    end

    it 'returns an error for an invalid action' do
      current_set = table.sets.last
      first_to_act_pos = (current_set.button_position + 3) % table.players.count
      first_to_act = table.players[first_to_act_pos]

      post "/api/tables/#{table.name}/action", {
        token: first_to_act.token,
        action_type: 'invalid_action',
        value: table.big_blind
      }.to_json, { 'CONTENT_TYPE' => 'application/json' }

      response_body = JSON.parse(last_response.body)
      expect(response_body['error']).to eq('Invalid action type')
    end

    it "returns an error if it's not the player's turn" do
      current_set = table.sets.last
      first_to_act_pos = (current_set.button_position + 3) % table.players.count
      not_to_act_pos = (first_to_act_pos + 1) % table.players.count
      not_to_act = table.players[not_to_act_pos]

      post "/api/tables/#{table.name}/action", {
        token: not_to_act.token,
        action_type: 'call',
        value: table.big_blind
      }.to_json, { 'CONTENT_TYPE' => 'application/json' }

      response_body = JSON.parse(last_response.body)
      expect(response_body['error']).to eq('Not your turn')
    end
  end

  describe 'GET /api/tables/:name/state' do
    context 'when no game is in progress' do
      it 'returns a "waiting" state' do
        get "/api/tables/#{table.name}/state", { token: player1.token }

        expect(last_response.status).to eq(200)
        expect(JSON.parse(last_response.body)['state']).to eq('waiting')
      end
    end

    context 'when a game is in progress' do
      before do
        post "/api/tables/#{table.name}/start", { token: player1.token }.to_json,
             { 'CONTENT_TYPE' => 'application/json' }
      end

      it 'returns the current game state' do
        get "/api/tables/#{table.name}/state", { token: player1.token }

        expect(last_response.status).to eq(200)

        response_body = JSON.parse(last_response.body)
        expect(response_body['state']).to eq('active')
        expect(response_body['game']['status']).to eq('preflop')
        expect(response_body['game']['pot']).to eq(table.small_blind + table.big_blind)

        expect(response_body['game']['players'].count).to eq(2)

        player1_data = response_body['game']['players'].find { |p| p['pseudo'] == player1.pseudo }
        expect(player1_data['cards']).not_to be_nil
      end
    end
  end
end
