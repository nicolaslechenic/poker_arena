# frozen_string_literal: true

require 'spec_helper'

RSpec.describe PokerArena::Application::UseCases::GetTableState do
  let(:players_repository) { PokerArena::Infrastructure::Repositories::PlayersRepository.new }
  let(:tables_repository) { PokerArena::Infrastructure::Repositories::TablesRepository.new }
  let(:table) { PokerArena::Domain::Entities::Table.new(tables_repository: tables_repository) }
  let(:player1) { PokerArena::Domain::Entities::Player.new(pseudo: 'Player1') }
  let(:player2) { PokerArena::Domain::Entities::Player.new(pseudo: 'Player2') }
  let(:use_case) { described_class.new(tables_repository) }

  before do
    players_repository.persist(player1)
    players_repository.persist(player2)
    tables_repository.persist(table)

    table.seat_in(player1)
    table.seat_in(player2)
  end

  describe '#call' do
    context 'when no game is in progress' do
      it 'returns a waiting state' do
        result = use_case.call(table.name)

        expect(result[:status]).to eq(200)
        expect(result[:state]).to eq('waiting')
        expect(result[:message]).to eq('No game in progress')
      end
    end

    context 'when a game is in progress' do
      before do
        table.start_game
      end

      it 'returns the current game state without player cards' do
        result = use_case.call(table.name)

        expect(result[:status]).to eq(200)
        expect(result[:state]).to eq('active')

        game_data = result[:game]
        expect(game_data[:status]).to eq(:preflop)

        expect(game_data[:pot]).to eq(table.small_blind + table.big_blind)
        expect(game_data[:board]).to be_a(Hash)
        expect(game_data[:players].count).to eq(2)

        game_data[:players].each do |player_data|
          expect(player_data).not_to have_key(:cards)
          expect(player_data[:pseudo]).to be_a(String)
          expect(player_data[:stack]).to be_a(Numeric)
          expect(player_data[:position]).to be_a(Integer)
        end
      end
    end
  end
end
