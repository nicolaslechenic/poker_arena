require 'spec_helper'

RSpec.describe PokerArena::FlushCombo do
  describe '#score' do
    it 'return expected array for Qc Jc Tc 3c 2c' do
      cards = PokerArena::Card.array('Qc Jc Tc 3c 2c')
      combo = described_class.new(cards: cards)

      expect(combo.score).to eql([5, 1_110_090_201])
    end
  end
end
