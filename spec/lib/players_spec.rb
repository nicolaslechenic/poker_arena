require 'spec_helper'

RSpec.describe PokerArena::Player do
  describe '#receive_card' do
    it 'raise an error for full of card player' do
      player = described_class.new

      %w[A K].each do |litteral|
        player.receive_card(PokerArena::Card.x(litteral))
      end

      expect {
        player.receive_card(PokerArena::Card.x('Q'))
      }.to raise_error(ArgumentError)
    end

    it 'return one card when added' do
      player = described_class.new
      player.receive_card(PokerArena::Card.x('Q'))

      expect(player.cards.count).to eql(1)
    end
  end
end
