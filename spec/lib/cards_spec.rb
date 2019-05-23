require 'spec_helper'

RSpec.describe PokerArena::Card do
  it 'return expected face and suit' do
    litterals = Fixtures.cards['cards']
    litteral = litterals[rand(litterals.size)]

    card_litteral = litteral.split(',').first
    card_value    = litteral.split(',')[1]
    card_suit     = litteral.split(',')[2]

    card = described_class.new(card_litteral)

    expect(card.value).to eql(card_value)
    expect(card.suit).to eql(card_suit)
  end

  describe '.all' do
    it 'return 52 cards' do
      expect(described_class.all.count).to eql(52)
    end
  end

  describe '.array' do
    it 'return 3 cards' do
      three_cards = described_class.array('3d As Qh')
      expect(three_cards.count).to eql(3)
    end
  end

  describe '.x' do
    it 'return fake card' do
      card = described_class.x('3')
      expect(card.value).to eql('3')
    end
  end

  describe '#score' do
    it 'return 1304 for As' do
      card = described_class.new('As')

      expect(card.score).to eql(1304)
    end
  end
end
