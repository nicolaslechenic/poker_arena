# frozen_string_literal: true

require 'spec_helper'

describe PokerArena::Infrastructure::Persistence::PlayerSerializer do
  let(:serializer) { described_class.new }

  let(:player) do
    player = PokerArena::Domain::Entities::Player.new(pseudo: 'player1')
    player.instance_variable_set('@token', 'abc123')
    player.cash.stack = 100.0
    player.all_in = false

    # Add some cards
    player.cards = [
      PokerArena::Domain::Entities::Card.new('Ah'),
      PokerArena::Domain::Entities::Card.new('Kd')
    ]

    player
  end

  describe '#serialize' do
    it 'converts a player to a hash' do
      result = serializer.serialize(player)

      expect(result).to be_a(Hash)
      expect(result['token']).to eq('abc123')
      expect(result['pseudo']).to eq('player1')
      expect(result['cash']).to be_a(Hash)
      expect(result['cards']).to be_an(Array)
      expect(result['cards'].size).to eq(2)
      expect(result['all_in']).to eq(false)
    end

    it 'serializes cash correctly' do
      result = serializer.serialize(player)

      cash = result['cash']
      expect(cash['bankroll']).to eq(player.cash.bankroll)
      expect(cash['stack']).to eq(100.0)
      expect(cash['stakes']).to eq(player.cash.stakes)
    end

    it 'serializes cards correctly' do
      result = serializer.serialize(player)

      cards = result['cards']
      expect(cards).to eq(%w[Ah Kd])
    end
  end

  describe '#deserialize' do
    let(:serialized_data) do
      {
        'token' => 'abc123',
        'pseudo' => 'player1',
        'cash' => {
          'bankroll' => 10_000,
          'stack' => 100.0,
          'stakes' => 0.0
        },
        'cards' => %w[Ah Kd],
        'all_in' => false
      }
    end

    it 'converts a hash to a player' do
      result = serializer.deserialize(serialized_data)

      expect(result).to be_a(PokerArena::Domain::Entities::Player)
      expect(result.token).to eq('abc123')
      expect(result.pseudo).to eq('player1')
      expect(result.cash).to be_a(PokerArena::Domain::Entities::Cash)
      expect(result.cards).to be_an(Array)
      expect(result.cards.size).to eq(2)
      expect(result.all_in).to eq(false)
    end

    it 'deserializes cash correctly' do
      result = serializer.deserialize(serialized_data)

      expect(result.cash.bankroll).to eq(10_000)
      expect(result.cash.stack).to eq(100.0)
      expect(result.cash.stakes).to eq(0.0)
    end

    it 'deserializes cards correctly' do
      result = serializer.deserialize(serialized_data)

      expect(result.cards[0].litteral).to eq('Ah')
      expect(result.cards[1].litteral).to eq('Kd')
    end
  end

  describe 'serialization roundtrip' do
    it 'preserves all data when serializing and deserializing' do
      serialized = serializer.serialize(player)
      deserialized = serializer.deserialize(serialized)

      expect(deserialized.token).to eq(player.token)
      expect(deserialized.pseudo).to eq(player.pseudo)
      expect(deserialized.cash.bankroll).to eq(player.cash.bankroll)
      expect(deserialized.cash.stack).to eq(player.cash.stack)
      expect(deserialized.cash.stakes).to eq(player.cash.stakes)
      expect(deserialized.cards.size).to eq(player.cards.size)
      expect(deserialized.cards[0].litteral).to eq(player.cards[0].litteral)
      expect(deserialized.cards[1].litteral).to eq(player.cards[1].litteral)
      expect(deserialized.all_in).to eq(player.all_in)
    end
  end
end
