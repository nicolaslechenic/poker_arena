# frozen_string_literal: true

require 'spec_helper'

describe PokerArena::Infrastructure::Persistence::HandHistorySerializer do
  let(:serializer) { described_class.new }
  let(:timestamp) { Time.now }

  let(:hand_history) do
    PokerArena::Domain::Entities::HandHistory.new(
      id: '1',
      table_name: 'azuria',
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
      timestamp: timestamp
    )
  end

  describe '#serialize' do
    it 'converts a hand history to a hash' do
      result = serializer.serialize(hand_history)

      expect(result).to be_a(Hash)
      expect(result['id']).to eq('1')
      expect(result['table_name']).to eq('azuria')
      expect(result['players']).to be_an(Array)
      expect(result['players'].size).to eq(2)
      expect(result['actions']).to be_an(Array)
      expect(result['actions'].size).to eq(2)
      expect(result['board_cards']).to be_a(Hash)
      expect(result['pot']).to eq(2.0)
      expect(result['winners']).to be_an(Array)
      expect(result['winners'].size).to eq(1)
      expect(result['timestamp']).to eq(timestamp.to_s)
    end

    it 'serializes players correctly' do
      result = serializer.serialize(hand_history)

      player = result['players'].first
      expect(player['pseudo']).to eq('player1')
      expect(player['position']).to eq(0)
      expect(player['initial_stack']).to eq(100.0)
    end

    it 'serializes actions correctly' do
      result = serializer.serialize(hand_history)

      action = result['actions'].first
      expect(action['player_position']).to eq(0)
      expect(action['player_pseudo']).to eq('player1')
      expect(action['type']).to eq('bet')
      expect(action['value']).to eq(1.0)
      expect(action['game_status']).to eq('preflop')
    end

    it 'serializes board cards correctly' do
      result = serializer.serialize(hand_history)

      board_cards = result['board_cards']
      expect(board_cards['flop']).to eq(%w[Ah 2d 7c])
      expect(board_cards['turn']).to eq('Ks')
      expect(board_cards['river']).to eq('10h')
    end

    it 'serializes winners correctly' do
      result = serializer.serialize(hand_history)

      winner = result['winners'].first
      expect(winner['player_position']).to eq(0)
      expect(winner['amount_won']).to eq(2.0)
    end
  end

  describe '#deserialize' do
    let(:serialized_data) do
      {
        'id' => '1',
        'table_name' => 'azuria',
        'players' => [
          { 'pseudo' => 'player1', 'position' => 0, 'initial_stack' => 100.0 },
          { 'pseudo' => 'player2', 'position' => 1, 'initial_stack' => 100.0 }
        ],
        'actions' => [
          { 'player_position' => 0, 'player_pseudo' => 'player1', 'type' => 'bet', 'value' => 1.0,
            'game_status' => 'preflop' },
          { 'player_position' => 1, 'player_pseudo' => 'player2', 'type' => 'call', 'value' => 1.0,
            'game_status' => 'preflop' }
        ],
        'board_cards' => {
          'flop' => %w[Ah 2d 7c],
          'turn' => 'Ks',
          'river' => '10h'
        },
        'pot' => 2.0,
        'winners' => [{ 'player_position' => 0, 'amount_won' => 2.0 }],
        'timestamp' => timestamp.to_s
      }
    end

    it 'converts a hash to a hand history' do
      result = serializer.deserialize(serialized_data)

      expect(result).to be_a(PokerArena::Domain::Entities::HandHistory)
      expect(result.id).to eq('1')
      expect(result.table_name).to eq('azuria')
      expect(result.players).to be_an(Array)
      expect(result.players.size).to eq(2)
      expect(result.actions).to be_an(Array)
      expect(result.actions.size).to eq(2)
      expect(result.board_cards).to be_a(Hash)
      expect(result.pot).to eq(2.0)
      expect(result.winners).to be_an(Array)
      expect(result.winners.size).to eq(1)
      expect(result.timestamp.to_s).to eq(timestamp.to_s)
    end

    it 'deserializes players correctly' do
      result = serializer.deserialize(serialized_data)

      player = result.players.first
      expect(player[:pseudo]).to eq('player1')
      expect(player[:position]).to eq(0)
      expect(player[:initial_stack]).to eq(100.0)
    end

    it 'deserializes actions correctly' do
      result = serializer.deserialize(serialized_data)

      action = result.actions.first
      expect(action[:player_position]).to eq(0)
      expect(action[:player_pseudo]).to eq('player1')
      expect(action[:type]).to eq(:bet)
      expect(action[:value]).to eq(1.0)
      expect(action[:game_status]).to eq(:preflop)
    end

    it 'deserializes board cards correctly' do
      result = serializer.deserialize(serialized_data)

      board_cards = result.board_cards
      expect(board_cards[:flop]).to eq(%w[Ah 2d 7c])
      expect(board_cards[:turn]).to eq('Ks')
      expect(board_cards[:river]).to eq('10h')
    end

    it 'deserializes winners correctly' do
      result = serializer.deserialize(serialized_data)

      winner = result.winners.first
      expect(winner[:player_position]).to eq(0)
      expect(winner[:amount_won]).to eq(2.0)
    end
  end

  describe 'serialization roundtrip' do
    it 'preserves all data when serializing and deserializing' do
      serialized = serializer.serialize(hand_history)
      deserialized = serializer.deserialize(serialized)

      expect(deserialized.id).to eq(hand_history.id)
      expect(deserialized.table_name).to eq(hand_history.table_name)
      expect(deserialized.players).to eq(hand_history.players)
      expect(deserialized.actions.size).to eq(hand_history.actions.size)
      expect(deserialized.actions[0][:type]).to eq(hand_history.actions[0][:type])
      expect(deserialized.board_cards[:flop]).to eq(hand_history.board_cards[:flop])
      expect(deserialized.pot).to eq(hand_history.pot)
      expect(deserialized.winners).to eq(hand_history.winners)
      expect(deserialized.timestamp.to_s).to eq(hand_history.timestamp.to_s)
    end
  end
end
