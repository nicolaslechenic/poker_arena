# frozen_string_literal: true

require 'spec_helper'

RSpec.describe PokerArena::Domain::Services::GameOrchestrator do
  let(:players_repository) { PokerArena::Infrastructure::Repositories::PlayersRepository.new }
  let(:tables_repository) { PokerArena::Infrastructure::Repositories::TablesRepository.new }
  let(:table) { PokerArena::Domain::Entities::Table.new(tables_repository: tables_repository) }
  let(:player1) { PokerArena::Domain::Entities::Player.new(pseudo: 'Player1') }
  let(:player2) { PokerArena::Domain::Entities::Player.new(pseudo: 'Player2') }
  let(:orchestrator) { described_class.new(table) }

  before do
    players_repository.persist(player1)
    players_repository.persist(player2)
    tables_repository.persist(table)

    table.seat_in(player1)
    table.seat_in(player2)
  end

  describe '#start_game' do
    it 'starts a game successfully' do
      expect(orchestrator.start_game).to be true

      expect(table.sets).not_to be_empty
      expect(table.sets.last.games).not_to be_empty
      expect(table.sets.last.games.last.status).to eq(:preflop)

      expect(player1.cards.count).to eq(2)
      expect(player2.cards.count).to eq(2)

      expect(table.pot).to eq(table.small_blind + table.big_blind)
    end

    it 'raises an error if not enough players' do
      table.seat_out(player2)
      expect { orchestrator.start_game }.to raise_error(StandardError, 'Not enough players to start a game')
    end
  end

  describe '#process_action' do
    before do
      orchestrator.start_game
    end

    it 'processes a valid action' do
      current_set = table.sets.last
      current_game = current_set.games.last

      first_to_act_pos = (current_set.button_position + 3) % table.players.count
      first_to_act = table.players[first_to_act_pos]

      expect(orchestrator.process_action(first_to_act, :call, table.big_blind)).to be true

      expect(current_game.actions.count).to eq(3)
      expect(current_game.actions.last.type).to eq(:call)
    end

    it 'returns false if not the player\'s turn' do
      current_set = table.sets.last
      first_to_act_pos = (current_set.button_position + 3) % table.players.count
      not_to_act_pos = (first_to_act_pos + 1) % table.players.count
      not_to_act = table.players[not_to_act_pos]

      expect(orchestrator.process_action(not_to_act, :call, table.big_blind)).to be false
    end
  end

  describe '#advance_game_status' do
    before do
      orchestrator.start_game
    end

    it 'advances the game status correctly' do
      current_game = table.sets.last.games.last
      expect(current_game.status).to eq(:preflop)

      first_to_act_pos = (table.sets.last.button_position + 3) % table.players.count
      first_to_act = table.players[first_to_act_pos]
      second_to_act_pos = (first_to_act_pos + 1) % table.players.count
      second_to_act = table.players[second_to_act_pos]

      orchestrator.process_action(first_to_act, :call, table.big_blind)
      orchestrator.process_action(second_to_act, :call, 0)

      expect(%i[flop turn].include?(current_game.status)).to be true
      expect(table.board.cards.count).to be >= 3
    end
  end

  describe '#determine_winner' do
    before do
      orchestrator.start_game
    end

    it 'determines the winner and distributes the pot' do
      table.sets.last.games.last

      first_to_act_pos = (table.sets.last.button_position + 3) % table.players.count
      first_to_act = table.players[first_to_act_pos]

      orchestrator.process_action(first_to_act, :fold, 0)

      initial_pot = table.pot
      expect(initial_pot).to be > 0
      orchestrator.determine_winner
      expect(table.pot).to eq(0)
    end
  end

  describe 'complete game flow' do
    it 'handles a complete hand correctly' do
      orchestrator.start_game

      current_set = table.sets.last
      current_game = current_set.games.last

      first_to_act_pos = (current_set.button_position + 3) % table.players.count
      first_to_act = table.players[first_to_act_pos]
      second_to_act_pos = (first_to_act_pos + 1) % table.players.count
      second_to_act = table.players[second_to_act_pos]

      orchestrator.process_action(first_to_act, :call, table.big_blind)
      orchestrator.process_action(second_to_act, :check, 0)

      # Advance to flop
      expect(current_game.status).to eq(:flop)
      expect(table.board.cards.count).to eq(3)

      # Process flop actions
      orchestrator.process_action(first_to_act, :check, 0)
      orchestrator.process_action(second_to_act, :check, 0)

      # Advance to turn
      expect(current_game.status).to eq(:turn)
      expect(table.board.cards.count).to eq(4)

      # Process turn actions
      orchestrator.process_action(first_to_act, :check, 0)
      orchestrator.process_action(second_to_act, :check, 0)

      # Advance to river
      expect(current_game.status).to eq(:river)
      expect(table.board.cards.count).to eq(5)

      # Process river actions
      orchestrator.process_action(first_to_act, :check, 0)
      orchestrator.process_action(second_to_act, :check, 0)

      # End the hand
      expect(table.pot).to eq(0)
      expect(current_set.button_position).to eq(1)
    end
  end
end
