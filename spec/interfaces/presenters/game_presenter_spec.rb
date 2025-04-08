# frozen_string_literal: true

require 'spec_helper'

RSpec.describe PokerArena::Interfaces::Presenters::GamePresenter do
  let(:presenter) { described_class.new }
  let(:tables_repository) { PokerArena::Infrastructure::Repositories::TablesRepository.new(nil, true) }
  let(:table) { PokerArena::Domain::Entities::Table.new(tables_repository: tables_repository) }
  let(:player1) { PokerArena::Domain::Entities::Player.new(pseudo: 'Player1') }
  let(:player2) { PokerArena::Domain::Entities::Player.new(pseudo: 'Player2') }
  let(:game_service) { PokerArena::Domain::Services::GameService.new }

  before do
    tables_repository.persist(table)
    table.seat_in(player1)
    table.seat_in(player2)
    table.start_game
  end

  describe '#current_player_data' do
    let(:current_set) { table.sets.last }

    it 'returns data for the current player' do
      result = presenter.current_player_data(table, current_set, game_service)

      expect(result).to be_a(Hash)
      expect(result[:pseudo]).to be_a(String)
      expect(result[:position]).to be_a(Integer)
    end

    context 'when set is nil' do
      it 'returns an empty hash' do
        result = presenter.current_player_data(table, nil, game_service)
        expect(result).to eq({})
      end
    end
  end

  describe '#board_data' do
    let(:board) { table.board }

    it 'returns data for the board' do
      result = presenter.board_data(board)

      expect(result).to be_a(Hash)
      expect(result).to have_key(:flop)
      expect(result).to have_key(:turn)
      expect(result).to have_key(:river)
    end
  end

  describe '#players_data' do
    it 'returns data for all players' do
      result = presenter.players_data(table, player1)

      expect(result).to be_an(Array)
      expect(result.count).to eq(2)

      player1_data = result.find { |p| p[:pseudo] == player1.pseudo }
      player2_data = result.find { |p| p[:pseudo] == player2.pseudo }

      expect(player1_data).to be_a(Hash)
      expect(player1_data[:pseudo]).to eq(player1.pseudo)
      expect(player1_data[:stack]).to be_a(Numeric)
      expect(player1_data[:position]).to be_a(Integer)
      expect(player1_data[:cards]).to be_an(Array)

      expect(player2_data).to be_a(Hash)
      expect(player2_data[:pseudo]).to eq(player2.pseudo)
      expect(player2_data[:stack]).to be_a(Numeric)
      expect(player2_data[:position]).to be_a(Integer)
      expect(player2_data).not_to have_key(:cards)
    end
  end

  describe '#game_state' do
    let(:current_set) { table.sets.last }
    let(:current_game) { current_set.games.last }

    it 'returns the complete game state' do
      result = presenter.game_state(table, player1, game_service)

      expect(result).to be_a(Hash)
      expect(result[:status]).to eq(:preflop)
      expect(result[:pot]).to be_a(Float)
      expect(result[:current_player]).to be_a(Hash)
      expect(result[:board]).to be_a(Hash)
      expect(result[:players]).to be_an(Array)
    end
  end

  describe '#waiting_state' do
    it 'returns a waiting state response' do
      result = presenter.waiting_state

      expect(result).to be_a(Hash)
      expect(result[:status]).to eq(200)
      expect(result[:state]).to eq('waiting')
      expect(result[:message]).to eq('No game in progress')
    end
  end

  describe '#active_state' do
    it 'returns an active state response' do
      game_data = { status: :preflop, pot: 10.0 }
      result = presenter.active_state(game_data)

      expect(result).to be_a(Hash)
      expect(result[:status]).to eq(200)
      expect(result[:state]).to eq('active')
      expect(result[:game]).to eq(game_data)
    end
  end

  describe '#action_success' do
    it 'returns a success response for an action' do
      result = presenter.action_success

      expect(result).to be_a(Hash)
      expect(result[:status]).to eq(200)
      expect(result[:message]).to eq('Action processed')
    end
  end

  describe '#game_start_success' do
    it 'returns a success response for game start' do
      result = presenter.game_start_success

      expect(result).to be_a(Hash)
      expect(result[:status]).to eq(200)
      expect(result[:message]).to eq('Game started')
    end
  end

  describe '#error' do
    it 'returns an error response' do
      result = presenter.error('Test error')

      expect(result).to be_a(Hash)
      expect(result[:status]).to eq(400)
      expect(result[:error]).to eq('Test error')
    end

    it 'allows custom status code' do
      result = presenter.error('Test error', 500)

      expect(result).to be_a(Hash)
      expect(result[:status]).to eq(500)
      expect(result[:error]).to eq('Test error')
    end
  end
end
