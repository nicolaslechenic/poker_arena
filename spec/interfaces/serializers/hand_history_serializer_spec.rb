# frozen_string_literal: true

require 'spec_helper'

describe PokerArena::Interfaces::Serializers::HandHistorySerializer do
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

  let(:hand_history) do
    PokerArena::Domain::Entities::HandHistory.new(
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

  subject { described_class.new(hand_history: hand_history) }

  describe '#call' do
    it 'serializes the hand history with all attributes' do
      result = subject.call

      expect(result[:id]).to eq(id)
      expect(result[:table_name]).to eq(table_name)
      expect(result[:players]).to eq(players)
      expect(result[:pot]).to eq(pot)
      expect(result[:board_cards]).to eq(board_cards)
      expect(result[:winners]).to eq(winners)
      expect(result[:timestamp]).to eq(timestamp)
    end

    it 'organizes actions by street' do
      result = subject.call

      expect(result[:actions]).to be_a(Hash)
      expect(result[:actions][:preflop].size).to eq(2)
      expect(result[:actions][:flop].size).to eq(3)
      expect(result[:actions][:turn]).to be_empty
      expect(result[:actions][:river]).to be_empty
    end

    it 'excludes specified attributes' do
      result = subject.call(without: %i[winners timestamp])

      expect(result).not_to have_key(:winners)
      expect(result).not_to have_key(:timestamp)
      expect(result).to have_key(:id)
      expect(result).to have_key(:table_name)
    end

    it 'includes additional attributes' do
      additional_data = { total_hands: 10, player_stats: { wins: 5, losses: 5 } }
      result = subject.call(with: additional_data)

      expect(result[:total_hands]).to eq(10)
      expect(result[:player_stats]).to eq({ wins: 5, losses: 5 })
    end
  end
end
