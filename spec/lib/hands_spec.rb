require 'spec_helper'

RSpec.describe PokerArena::Hand do
  it 'return return six combos for six cards in hand' do
    six_cards = PokerArena::Card.array('Ad 5s 6h 7c Tc 2s')
    hand = described_class.new(cards: six_cards)

    expect(hand.combos.count).to eql(6)
  end
end
