# frozen_string_literal: true

require 'spec_helper'

RSpec.describe PokerArena::Domain::Services::GameProgressionService do
  let(:service) { described_class.new }
  let(:tables_repository) { PokerArena::Infrastructure::Repositories::TablesRepository.new(nil, true) }
  let(:table) { PokerArena::Domain::Entities::Table.new(tables_repository: tables_repository) }
  let(:player1) { PokerArena::Domain::Entities::Player.new(pseudo: 'Player1') }
  let(:player2) { PokerArena::Domain::Entities::Player.new(pseudo: 'Player2') }

  before do
    tables_repository.persist(table)
    table.seat_in(player1)
    table.seat_in(player2)
    table.start_game
  end

  describe '#advance_game_status' do
    let(:current_set) { table.sets.last }
    let(:current_game) { current_set.games.last }

    context 'when game status is preflop' do
      it 'advances to flop' do
        expect(current_game.status).to eq(:preflop)
        expect(table.board.cards.count).to eq(0)

        service.advance_game_status(table, current_set, current_game)

        expect(current_game.status).to eq(:flop)
        expect(table.board.cards.count).to eq(3)
      end
    end

    context 'when game status is flop' do
      before do
        current_game.status = :flop
        3.times { table.dealer.deal(table.board) }
      end

      it 'advances to turn' do
        expect(current_game.status).to eq(:flop)
        expect(table.board.cards.count).to eq(3)

        service.advance_game_status(table, current_set, current_game)

        expect(current_game.status).to eq(:turn)
        expect(table.board.cards.count).to eq(4)
      end
    end

    context 'when game status is turn' do
      before do
        current_game.status = :turn
        4.times { table.dealer.deal(table.board) }
      end

      it 'advances to river' do
        expect(current_game.status).to eq(:turn)
        expect(table.board.cards.count).to eq(4)

        service.advance_game_status(table, current_set, current_game)

        expect(current_game.status).to eq(:river)
        expect(table.board.cards.count).to eq(5)
      end
    end

    context 'when game status is river' do
      before do
        current_game.status = :river
        5.times { table.dealer.deal(table.board) }

        player1.cards = [
          PokerArena::Domain::Entities::Card.new('Ah'),
          PokerArena::Domain::Entities::Card.new('Kh')
        ]

        player2.cards = [
          PokerArena::Domain::Entities::Card.new('2c'),
          PokerArena::Domain::Entities::Card.new('3d')
        ]

        table.pot = 10.0
      end

      it 'ends the hand and determines the winner' do
        expect(current_game.status).to eq(:river)

        initial_button_position = current_set.button_position
        initial_pot = table.pot
        initial_player1_cash = player1.cash.amount
        initial_player2_cash = player2.cash.amount

        service.advance_game_status(table, current_set, current_game)

        expect(current_set.button_position).to eq((initial_button_position + 1) % table.players.count)
        expect(table.pot).to eq(0)
        expect(player1.cash.amount + player2.cash.amount).to eq(initial_player1_cash + initial_player2_cash + initial_pot)
      end
    end
  end

  describe '#determine_winner' do
    before do
      player1.cards = [
        PokerArena::Domain::Entities::Card.new('Ah'),
        PokerArena::Domain::Entities::Card.new('Kh')
      ]

      player2.cards = [
        PokerArena::Domain::Entities::Card.new('2c'),
        PokerArena::Domain::Entities::Card.new('3d')
      ]

      board_cards = [
        PokerArena::Domain::Entities::Card.new('Qh'),
        PokerArena::Domain::Entities::Card.new('Jh'),
        PokerArena::Domain::Entities::Card.new('Th'),
        PokerArena::Domain::Entities::Card.new('9s'),
        PokerArena::Domain::Entities::Card.new('8d')
      ]

      new_board = PokerArena::Domain::Entities::Board.new
      board_cards.each { |card| new_board.receive_card(card) }

      table.instance_variable_set(:@board, new_board)
      table.pot = 10.0
    end

    it 'awards the pot to the player with the best hand' do
      initial_player1_cash = player1.cash.amount

      service.determine_winner(table)

      expect(player1.cash.amount).to eq(initial_player1_cash + 10.0)
      expect(table.pot).to eq(0)
    end
  end
end
