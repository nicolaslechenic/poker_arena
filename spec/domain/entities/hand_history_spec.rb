# frozen_string_literal: true

require 'spec_helper'

describe PokerArena::Domain::Entities::HandHistory do
  let(:id) { '1' }
  let(:table_name) { 'azuria' }
  let(:players) do
    [
      { pseudo: 'player1', position: 0, initial_stack: 100.0 },
      { pseudo: 'player2', position: 1, initial_stack: 100.0 }
    ]
  end
  let(:actions) do
    [
      { player_position: 0, player_pseudo: 'player1', type: :bet, value: 1.0, game_status: :preflop },
      { player_position: 1, player_pseudo: 'player2', type: :call, value: 1.0, game_status: :preflop },
      { player_position: 0, player_pseudo: 'player1', type: :check, value: 0.0, game_status: :flop },
      { player_position: 1, player_pseudo: 'player2', type: :bet, value: 2.0, game_status: :flop },
      { player_position: 0, player_pseudo: 'player1', type: :fold, value: 0.0, game_status: :flop }
    ]
  end
  let(:board_cards) do
    {
      flop: %w[Ah 2d 7c],
      turn: 'Ks',
      river: '10h'
    }
  end
  let(:pot) { 4.0 }
  let(:winners) do
    [
      { player_position: 1, amount_won: 4.0 }
    ]
  end
  let(:timestamp) { Time.now }

  subject do
    described_class.new(
      id: id,
      table_name: table_name,
      players: players,
      actions: actions,
      board_cards: board_cards,
      pot: pot,
      winners: winners,
      timestamp: timestamp
    )
  end

  describe '#initialize' do
    it 'creates a hand history with the given attributes' do
      expect(subject.id).to eq(id)
      expect(subject.table_name).to eq(table_name)
      expect(subject.players).to eq(players)
      expect(subject.actions).to eq(actions)
      expect(subject.board_cards).to eq(board_cards)
      expect(subject.pot).to eq(pot)
      expect(subject.winners).to eq(winners)
      expect(subject.timestamp).to eq(timestamp)
    end
  end

  describe '#player_actions' do
    it 'returns actions for a specific player position' do
      player_actions = subject.player_actions(0)
      expect(player_actions.size).to eq(3)
      expect(player_actions.map { |a| a[:type] }).to eq(%i[bet check fold])
    end
  end

  describe '#actions_by_street' do
    it 'returns actions for a specific street' do
      preflop_actions = subject.actions_by_street(:preflop)
      expect(preflop_actions.size).to eq(2)
      expect(preflop_actions.map { |a| a[:player_pseudo] }).to eq(%w[player1 player2])

      flop_actions = subject.actions_by_street(:flop)
      expect(flop_actions.size).to eq(3)
      expect(flop_actions.map { |a| a[:type] }).to eq(%i[check bet fold])
    end
  end

  describe '#preflop_actions' do
    it 'returns all preflop actions' do
      expect(subject.preflop_actions.size).to eq(2)
      expect(subject.preflop_actions.map { |a| a[:type] }).to eq(%i[bet call])
    end
  end

  describe '#flop_actions' do
    it 'returns all flop actions' do
      expect(subject.flop_actions.size).to eq(3)
      expect(subject.flop_actions.map { |a| a[:type] }).to eq(%i[check bet fold])
    end
  end

  describe '#turn_actions' do
    it 'returns all turn actions' do
      expect(subject.turn_actions).to be_empty
    end
  end

  describe '#river_actions' do
    it 'returns all river actions' do
      expect(subject.river_actions).to be_empty
    end
  end

  describe '#player_at_position' do
    it 'returns the player at the specified position' do
      player = subject.player_at_position(1)
      expect(player).to eq(players[1])
      expect(player[:pseudo]).to eq('player2')
    end
  end
end
