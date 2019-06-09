require 'spec_helper'

RSpec.describe PokerArena::Player do
  describe '.generate' do
    it 'return 10 characters token' do
      expect(described_class.generate.size).to eql(10)
    end
  end

  describe '.valid_token' do
    it 'return true for created token' do
      token = PokerArena::Player.generate
      token_is_valid = PokerArena::Player.valid_token?(token)

      expect(token_is_valid).to eql(true)
    end

    it 'return false for random token' do
      token = SecureRandom.hex(5)
      token_is_invalid = PokerArena::Player.valid_token?(token)

      expect(token_is_invalid).to eql(false)
    end
  end

  describe '#receive_card' do
    it 'raise an error for full of card player' do
      player = described_class.new

      %w[A K].each do |litteral|
        player.receive_card(PokerArena::Card.x(litteral))
      end

      expect do
        player.receive_card(PokerArena::Card.x('Q'))
      end.to raise_error(RangeError)
    end

    it 'raise an error for card with wrong type' do
      player = described_class.new

      expect do
        player.receive_card('Qs')
      end.to raise_error(TypeError)
    end

    it 'return one card when added' do
      player = described_class.new
      player.receive_card(PokerArena::Card.x('Q'))

      expect(player.cards.count).to eql(1)
    end
  end
end
