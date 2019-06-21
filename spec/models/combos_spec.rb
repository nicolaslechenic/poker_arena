require 'spec_helper'

RSpec.describe PokerArena::Combo do
  it 'raise exception for too many cards' do
    cards = PokerArena::Card.array('7c Jc Tc 8c 9c 5s')
    expect { described_class.new(cards: cards) }.to raise_error(RangeError)
  end

  describe '.straights' do
    it 'return all possible straights combos' do
      count_straight = Fixtures.straights['straights'].count
      expect(described_class.straights.count).to eql(count_straight)
    end
  end

  describe '#royal_flush?' do
    it "return false when it's not a royal flush" do
      cards = PokerArena::Card.array('Jc Tc 8c 9c 7c ')
      combo = described_class.for(cards: cards)


      expect(combo.royal_flush?).to eql(false)
    end

    it "return true when it's a royal flush" do
      cards = PokerArena::Card.array('Ac Kc Qc Jc Tc')
      combo = described_class.for(cards: cards)

      expect(combo.royal_flush?).to eql(true)
    end
  end

  describe '#straight_flush?' do
    it "return false when it's not a straight flush" do
      cards = PokerArena::Card.array('Jc Th 8c 9c 7c')
      combo = described_class.for(cards: cards)

      expect(combo.straight_flush?).to eql(false)
    end

    it "return true when it's a straight flush" do
      cards = PokerArena::Card.array('Jc Tc 9c 8c 7c')
      combo = described_class.for(cards: cards)

      expect(combo.straight_flush?).to eql(true)
    end
  end

  describe '#four_of_a_kind?' do
    it "return false when it's not a four of a kind combo" do
      cards = PokerArena::Card.array('Jc Ts 8c 9c 7h')
      combo = described_class.for(cards: cards)

      expect(combo.four_of_a_kind?).to eql(false)
    end

    it "return true when it's a four of a kind combo" do
      cards = PokerArena::Card.array('8h 8d 8s 8c 9c')
      combo = described_class.for(cards: cards)

      expect(combo.four_of_a_kind?).to eql(true)
    end
  end

  describe '#full_house?' do
    it "return false when it's not a full house" do
      cards = PokerArena::Card.array('7h Qc As 8c 9c')
      combo = described_class.for(cards: cards)

      expect(combo.full_house?).to eql(false)
    end

    it "return true when it's a full house" do
      cards = PokerArena::Card.array('Td Ts Tc 8c 8s')
      combo = described_class.for(cards: cards)

      expect(combo.full_house?).to eql(true)
    end
  end

  describe '#flush?' do
    it "return false when it's not a flush" do
      cards = PokerArena::Card.array('7h Qc As 8c 9c')
      combo = described_class.for(cards: cards)

      expect(combo.flush?).to eql(false)
    end

    it 'return false when they are less than five cards' do
      cards = PokerArena::Card.array('Qc Ac 8c 9c')
      combo = described_class.for(cards: cards)

      expect(combo.flush?).to eql(false)
    end

    it "return true when it's a flush" do
      cards = PokerArena::Card.array('7c Qc Tc 8c 9c')
      combo = described_class.for(cards: cards)

      expect(combo.flush?).to eql(true)
    end
  end

  describe '#straight?' do
    it "return false when it's not a straight" do
      cards = PokerArena::Card.array('Qc As 8c 9c 7h')
      combo = described_class.for(cards: cards)

      expect(combo.straight?).to eql(false)
    end

    it "return true when it's a straight" do
      cards = PokerArena::Card.array('Jc Ts 9c 8c 7h')
      combo = described_class.for(cards: cards)

      expect(combo.straight?).to eql(true)
    end
  end

  describe '#three_of_a_kind?' do
    it "return false when it's not a three of a kind combo" do
      cards = PokerArena::Card.array('7h Jc Ts 8c 9c')
      combo = described_class.for(cards: cards)

      expect(combo.three_of_a_kind?).to eql(false)
    end

    it "return true when it's a three of a kind combo" do
      cards = PokerArena::Card.array('8h Qc 8s 8c 9c')
      combo = described_class.for(cards: cards)

      expect(combo.three_of_a_kind?).to eql(true)
    end
  end

  describe '#two_pairs?' do
    it "return false when it's not a two pairs combo" do
      cards = PokerArena::Card.array('7h Jc Ts 8c 9c')
      combo = described_class.for(cards: cards)

      expect(combo.two_pairs?).to eql(false)
    end

    it "return true when it's a two pairs combo" do
      cards = PokerArena::Card.array('9h Qc 8s 8c 9c')
      combo = described_class.for(cards: cards)

      expect(combo.two_pairs?).to eql(true)
    end
  end

  describe '#pair?' do
    it "return false when it's not a pair combo" do
      cards = PokerArena::Card.array('7h Jc Ts 8c 9c')
      combo = described_class.for(cards: cards)

      expect(combo.pair?).to eql(false)
    end

    it "return true when it's a pair combo" do
      cards = PokerArena::Card.array('6h Qc 8s 8c 9c')
      combo = described_class.for(cards: cards)

      expect(combo.pair?).to eql(true)
    end
  end

  describe '#high_card?' do
    it "return true when it's only a high card combo" do
      cards = PokerArena::Card.array('6h Qc 3s 8c 9c')
      combo = described_class.for(cards: cards)

      expect(combo.high_card?).to eql(true)
    end
  end

  describe '#score' do
    it 'return expected array for Ac 8d 4c 3c 2c' do
      cards = PokerArena::Card.array('Ac 8d 4c 3c 2c')
      combo = described_class.new(cards: cards)

      expect(combo.score).to eql([0, 1_307_030_201])
    end
  end
end
