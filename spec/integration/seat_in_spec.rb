# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Seat in behavior', type: :integration do
  let(:players_repository) { PokerArena::Infrastructure::Repositories::PlayersRepository.new }
  let(:tables_repository) { PokerArena::Infrastructure::Repositories::TablesRepository.new(nil, true) }
  let(:table) { PokerArena::Domain::Entities::Table.new(tables_repository: tables_repository) }

  describe 'when seating in a player' do
    context 'with less than 10x big blind in bankroll' do
      it 'raises an error' do
        player = PokerArena::Domain::Entities::Player.new(pseudo: 'Player1')
        player.cash.bankroll = table.big_blind * 9

        expect do
          table.seat_in(player)
        end.to raise_error(StandardError, "Not enough bankroll (minimum #{table.big_blind * 10})")
      end
    end

    context 'with more than 10x but less than 100x big blind in bankroll' do
      it 'transfers all bankroll to stack' do
        player = PokerArena::Domain::Entities::Player.new(pseudo: 'Player1')
        player.cash.bankroll = table.big_blind * 50
        initial_bankroll = player.cash.bankroll

        table.seat_in(player)

        expect(player.cash.stack).to eq(initial_bankroll)
        expect(player.cash.bankroll).to eq(0)
      end
    end

    context 'with more than 100x big blind in bankroll' do
      it 'transfers 100x big blind to stack' do
        player = PokerArena::Domain::Entities::Player.new(pseudo: 'Player1')
        player.cash.bankroll = table.big_blind * 200
        initial_bankroll = player.cash.bankroll

        table.seat_in(player)

        expect(player.cash.stack).to eq(table.big_blind * 100)
        expect(player.cash.bankroll).to eq(initial_bankroll - (table.big_blind * 100))
      end
    end
  end
end
