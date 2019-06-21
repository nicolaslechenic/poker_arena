require 'spec_helper'

RSpec.describe PokerArena::PairCombo do
  describe '#score' do
    it 'return expected array for 7h Qc As 8c 9c' do
      cards = PokerArena::Card.array('7h Qc As 8c 9c')
      combo = described_class.new(cards: cards)

      expect(combo.score).to eql([0, 1_311_080_706])
    end
  end
end
