# frozen_string_literal: true

require 'spec_helper'

RSpec.describe PokerArena::Domain::Services::GameService do
  let(:service) { described_class.new }
  let(:tables_repository) { PokerArena::Infrastructure::Repositories::TablesRepository.new }
  let(:table) { PokerArena::Domain::Entities::Table.new(tables_repository: tables_repository) }
  let(:player1) { PokerArena::Domain::Entities::Player.new(pseudo: 'Player1') }
  let(:player2) { PokerArena::Domain::Entities::Player.new(pseudo: 'Player2') }

  before do
    tables_repository.persist(table)
    table.seat_in(player1)
    table.seat_in(player2)
    table.start_game
  end

  describe '#player_folded?' do
    let(:game) { table.sets.last.games.last }

    context 'when player has not folded' do
      it 'returns false' do
        expect(service.player_folded?(player1, game)).to be false
      end
    end

    context 'when player has folded' do
      before do
        action = PokerArena::Domain::Entities::Action.new(player: player1, type: :fold, value: 0)
        game.add_action(action)
      end

      it 'returns true' do
        expect(service.player_folded?(player1, game)).to be true
      end
    end
  end

  describe '#active_players' do
    let(:game) { table.sets.last.games.last }

    context 'when no players have folded' do
      it 'returns all players' do
        active_players = service.active_players(table, game)
        expect(active_players.count).to eq(2)
        expect(active_players).to include(player1)
        expect(active_players).to include(player2)
      end
    end

    context 'when a player has folded' do
      before do
        action = PokerArena::Domain::Entities::Action.new(player: player1, type: :fold, value: 0)
        game.add_action(action)
      end

      it 'returns only active players' do
        active_players = service.active_players(table, game)
        expect(active_players.count).to eq(1)
        expect(active_players).to include(player2)
        expect(active_players).not_to include(player1)
      end
    end
  end

  describe '#current_player_position' do
    let(:set) { table.sets.last }
    let(:game) { set.games.last }

    it 'returns the position of the current player' do
      position = service.current_player_position(table, set)
      expect(position).to be_a(Integer)
      expect(position).to be >= 0
      expect(position).to be < table.players.count
    end

    context 'at the beginning of preflop' do
      it 'returns the position after the big blind' do
        expected_position = (set.button_position + 3) % table.players.count
        expect(service.current_player_position(table, set)).to eq(expected_position)
      end
    end
  end

  describe '#player_bet' do
    let(:game) { table.sets.last.games.last }

    it 'returns the total bet amount for a player' do
      small_blind_pos = (table.sets.last.button_position + 1) % table.players.count
      big_blind_pos = (table.sets.last.button_position + 2) % table.players.count

      small_blind_player = table.players[small_blind_pos]
      big_blind_player = table.players[big_blind_pos]

      expect(service.player_bet(small_blind_player, game)).to eq(table.small_blind)
      expect(service.player_bet(big_blind_player, game)).to eq(table.big_blind)
    end

    context 'when a player makes additional bets' do
      before do
        action = PokerArena::Domain::Entities::Action.new(player: player1, type: :call, value: table.big_blind)
        game.add_action(action)
      end

      it 'returns the sum of all bets' do
        expect(service.player_bet(player1, game)).to be > 0
      end
    end
  end

  describe '#current_bet' do
    let(:game) { table.sets.last.games.last }

    it 'returns the current highest bet in the game' do
      expect(service.current_bet(game)).to eq(table.big_blind)
    end

    context 'when a player raises' do
      before do
        action = PokerArena::Domain::Entities::Action.new(player: player1, type: :raise, value: table.big_blind * 2)
        game.add_action(action)
      end

      it 'returns the new highest bet' do
        expect(service.current_bet(game)).to eq(table.big_blind * 2)
      end
    end
  end

  describe '#find_best_hand_player' do
    let(:board) { table.board }

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
    end

    it 'returns the player with the best hand' do
      best_player = service.find_best_hand_player([player1, player2], board)
      expect(best_player).to eq(player1)
    end
  end
end
