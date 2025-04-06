# frozen_string_literal: true

require 'spec_helper'
require 'rack/test'

describe PokerArena::Interfaces::Controllers::GamesController do
  include Rack::Test::Methods

  let(:hand_histories_repository) { PokerArena::Infrastructure::Repositories::HandHistoriesRepository.new }
  let(:tables_repository) { PokerArena::Infrastructure::Repositories::TablesRepository.new(nil, true) }
  let(:players_repository) { PokerArena::Infrastructure::Repositories::PlayersRepository.new }
  let(:table_name) { 'azuria' }

  let(:hand_history) do
    PokerArena::Domain::Entities::HandHistory.new(
      id: nil,
      table_name: table_name,
      players: [
        { pseudo: 'player1', position: 0, initial_stack: 100.0 },
        { pseudo: 'player2', position: 1, initial_stack: 100.0 }
      ],
      actions: [
        { player_position: 0, player_pseudo: 'player1', type: :bet, value: 1.0, game_status: :preflop },
        { player_position: 1, player_pseudo: 'player2', type: :call, value: 1.0, game_status: :preflop }
      ],
      board_cards: {
        flop: %w[Ah 2d 7c],
        turn: 'Ks',
        river: '10h'
      },
      pot: 2.0,
      winners: [{ player_position: 0, amount_won: 2.0 }],
      timestamp: Time.now
    )
  end

  let(:controller_class) do
    Class.new(PokerArena::Interfaces::Controllers::GamesController) do
      configure do
        disable :protection
        set :environment, :test
        set :show_exceptions, false
        set :raise_errors, true
      end
    end
  end

  def app
    process_action_use_case = PokerArena::Application::UseCases::ProcessAction.new(
      tables_repository,
      players_repository,
      hand_histories_repository
    )

    controller_class.new(
      ->(_env) { [404, { 'Content-Type' => 'text/plain' }, ['Not Found']] },
      tables_repository: tables_repository,
      players_repository: players_repository,
      hand_histories_repository: hand_histories_repository,
      process_action_use_case: process_action_use_case
    )
  end

  before do
    hand_histories_repository.clear
    PokerArena::Application::UseCases::InitializeTables.new(tables_repository).call
    @persisted_history = hand_histories_repository.persist(hand_history)
  end

  describe 'GET /api/hand_histories/:id' do
    it 'returns a hand history by ID' do
      get "/api/hand_histories/#{@persisted_history.id}"

      expect(last_response.status).to eq(200)

      response_body = JSON.parse(last_response.body)
      expect(response_body['status']).to eq(200)
      expect(response_body['hand_history']['id']).to eq(@persisted_history.id)
      expect(response_body['hand_history']['table_name']).to eq(table_name)
    end

    it 'returns a 404 error when the hand history is not found' do
      get '/api/hand_histories/999'

      expect(last_response.status).to eq(200)

      response_body = JSON.parse(last_response.body)
      expect(response_body['status']).to eq(404)
      expect(response_body['error']).to include('not found')
    end
  end

  describe 'GET /api/tables/:name/hand_histories' do
    it 'returns all hand histories for a table' do
      hand_histories_repository.persist(hand_history)

      get "/api/tables/#{table_name}/hand_histories"

      expect(last_response.status).to eq(200)

      response_body = JSON.parse(last_response.body)
      expect(response_body['status']).to eq(200)
      expect(response_body['hand_histories'].size).to eq(2)
      expect(response_body['hand_histories'][0]['table_name']).to eq(table_name)
    end

    it 'returns an empty array when no histories exist for the table' do
      get '/api/tables/nonexistent/hand_histories'

      expect(last_response.status).to eq(200)

      response_body = JSON.parse(last_response.body)
      expect(response_body['status']).to eq(200)
      expect(response_body['hand_histories']).to be_empty
    end
  end

  describe 'POST /api/tables/:name/save_hand_history' do
    it 'saves the current hand as a history' do
      table = tables_repository.find(table_name)
      player1 = PokerArena::Domain::Entities::Player.new(pseudo: 'player1')
      player2 = PokerArena::Domain::Entities::Player.new(pseudo: 'player2')
      table.players << player1
      table.players << player2

      set = PokerArena::Domain::Entities::Set.new(players: table.players)
      game = PokerArena::Domain::Entities::Game.new(status: :river)

      action1 = PokerArena::Domain::Entities::Action.new(player: player1, type: :bet, value: 1.0)
      action2 = PokerArena::Domain::Entities::Action.new(player: player2, type: :call, value: 1.0)

      game.add_action(action1)
      game.add_action(action2)

      set.add_game(game)
      table.sets << set

      table.board.receive_card(PokerArena::Domain::Entities::Card.new('Ah'))
      table.board.receive_card(PokerArena::Domain::Entities::Card.new('2d'))
      table.board.receive_card(PokerArena::Domain::Entities::Card.new('7c'))
      table.board.receive_card(PokerArena::Domain::Entities::Card.new('Ks'))
      table.board.receive_card(PokerArena::Domain::Entities::Card.new('Td'))

      allow(table).to receive(:round_completed?).and_return(true)

      initial_count = hand_histories_repository.all.size

      post "/api/tables/#{table_name}/save_hand_history"

      expect(last_response.status).to eq(200)

      response_body = JSON.parse(last_response.body)
      expect(response_body['status']).to eq(200)
      expect(response_body['message']).to include('saved successfully')

      expect(hand_histories_repository.all.size).to eq(initial_count + 1)
    end

    it 'returns an error when there is no active game' do
      post '/api/tables/balamb/save_hand_history'

      expect(last_response.status).to eq(200) 

      response_body = JSON.parse(last_response.body)
      expect(response_body['status']).to eq(400)
      expect(response_body['error']).to include('No active game found')
    end
  end
end
