require 'spec_helper'

RSpec.describe PokerArena::FullHouseCombo do
  describe '#score' do
    it 'return expected array for Ad 2h As Ac 2c' do
      cards = PokerArena::Card.array('Ad 2h As Ac 2c')
      combo = described_class.new(cards: cards)

      expect(combo.score).to eql([6, 13])
    end
  end
end
