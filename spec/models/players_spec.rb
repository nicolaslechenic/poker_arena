require 'spec_helper'

RSpec.describe PokerArena::Player do
  describe '#receive_card' do
    it 'raise an error for full of card player' do
      player = described_class.new(pseudo: 'Wall-e', password: 'password123')

      %w[A K].each do |litteral|
        player.receive_card(PokerArena::Card.x(litteral))
      end

      expect do
        player.receive_card(PokerArena::Card.x('Q'))
      end.to raise_error(RangeError)
    end

    it 'raise an error for card with wrong type' do
      player = described_class.new(pseudo: 'Wall-e', password: 'password123')

      expect do
        player.receive_card('Qs')
      end.to raise_error(TypeError)
    end

    it 'return one card when added' do
      player = described_class.new(pseudo: 'Wall-e', password: 'password123')
      player.receive_card(PokerArena::Card.x('Q'))

      expect(player.cards.count).to eql(1)
    end
  end
end
