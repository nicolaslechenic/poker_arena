require 'spec_helper'

RSpec.describe PokerArena::FourOfAKindCombo do
  describe '#score' do
    it 'return expected array for Ad Ah Qc As Ac' do
      cards = PokerArena::Card.array('Ad Ah Qc As Ac')
      combo = described_class.new(cards: cards)

      expect(combo.score).to eql([7, 13])
    end
  end
end
