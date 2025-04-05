# frozen_string_literal: true

require 'spec_helper'

RSpec.describe PokerArena::Application::UseCases::GetTableState do
  let(:players_repository) do
    PokerArena::Infrastructure::Repositories::PlayersRepository.new
  end

  let(:tables_repository) do
    PokerArena::Infrastructure::Repositories::TablesRepository.new(nil, true)
  end

  let(:table) do
    PokerArena::Domain::Entities::Table.new(tables_repository: tables_repository)
  end

  let(:player1) do
    PokerArena::Domain::Entities::Player.new(pseudo: 'Player1')
  end

  let(:player2) do
    PokerArena::Domain::Entities::Player.new(pseudo: 'Player2')
  end

  let(:use_case) do
    described_class.new(tables_repository)
  end

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
      let(:expected_result) do
        {
          status: 200,
          state: 'active',
          game: {
            board: {
              flop: [],
              turn: nil,
              river: nil
            },
            current_player: {
              pseudo: 'Player2',
              position: 1
            },
            status: :preflop,
            pot: (table.small_blind + table.big_blind),
            players: [
              {
                pseudo: 'Player1',
                stack: 99,
                position: 0
              },
              {
                pseudo: 'Player2',
                stack: 99.5,
                position: 1
              }
            ]
          }
        }
      end

      before do
        table.start_game
      end

      it 'returns the current game state without player cards' do
        result = use_case.call(table.name)

        expect(result).to eq(expected_result)
      end
    end
  end
end
