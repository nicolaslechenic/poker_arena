require 'spec_helper'

RSpec.describe PokerArena::StraightFlushCombo do
  describe '#score' do
    it 'return expected array for Ac 5c 4c 3c 2c' do
      cards = PokerArena::Card.array('Ac 5c 4c 3c 2c')
      combo = described_class.new(cards: cards)

      expect(combo.score).to eql([8, 4])
    end
  end
end
