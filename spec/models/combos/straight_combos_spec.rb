require 'spec_helper'

RSpec.describe PokerArena::StraightCombo do
  describe '#score' do
    it 'return expected array for Ad 5s 4c 3c 2c' do
      cards = PokerArena::Card.array('Ad 5s 4c 3c 2c')
      combo = described_class.new(cards: cards)

      expect(combo.score).to eql([4, 4])
    end

    it 'return expected array for Ad Kh Qc Js Tc' do
      cards = PokerArena::Card.array('Ad Kh Qc Js Tc')
      combo = described_class.new(cards: cards)

      expect(combo.score).to eql([4, 13])
    end

  end
end
