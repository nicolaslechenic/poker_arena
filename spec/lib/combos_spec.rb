require 'spec_helper'

RSpec.describe PokerArena::Combo do
  describe '.straights' do
    it 'return all possible straights combos' do
      expect(described_class.straights.count).to eql(Fixtures.straights['straights'].count)
    end
  end

  describe '#royal_flush?' do
    it "return false when it's not a royal flush" do
      cards = PokerArena::Card.array('7c Jc Tc 8c 9c')
      combo = described_class.new(cards: cards)

      expect(combo.royal_flush?).to eql(false)
    end

    it "return true when it's a royal flush" do
      cards = PokerArena::Card.array('Qc Jc Tc Kc Ac')
      combo = described_class.new(cards: cards)

      expect(combo.royal_flush?).to eql(true)
    end
  end

  describe '#straight_flush?' do
    it "return false when it's not a straight flush" do
      cards = PokerArena::Card.array('7c Jc Th 8c 9c')
      combo = described_class.new(cards: cards)

      expect(combo.straight_flush?).to eql(false)
    end

    it "return true when it's a straight flush" do
      cards = PokerArena::Card.array('7c Jc Tc 8c 9c')
      combo = described_class.new(cards: cards)

      expect(combo.straight?).to eql(true)
    end
  end

  describe '#four_of_a_kind?' do
    it "return false when it's not a four of a kind combo" do
      cards = PokerArena::Card.array('7h Jc Ts 8c 9c')
      combo = described_class.new(cards: cards)

      expect(combo.four_of_a_kind?).to eql(false)
    end

    it "return true when it's a four of a kind combo" do
      cards = PokerArena::Card.array('8h 8d 8s 8c 9c')
      combo = described_class.new(cards: cards)

      expect(combo.four_of_a_kind?).to eql(true)
    end
  end

  describe '#full_house?' do
    it "return false when it's not a full house" do
      cards = PokerArena::Card.array('7h Qc As 8c 9c')
      combo = described_class.new(cards: cards)

      expect(combo.full_house?).to eql(false)
    end

    it "return true when it's a full house" do
      cards = PokerArena::Card.array('Td Ts Tc 8c 8s')
      combo = described_class.new(cards: cards)

      expect(combo.full_house?).to eql(true)
    end
  end

  describe '#flush?' do
    it "return false when it's not a flush" do
      cards = PokerArena::Card.array('7h Qc As 8c 9c')
      combo = described_class.new(cards: cards)

      expect(combo.flush?).to eql(false)
    end

    it 'return false when they are less than five cards' do
      cards = PokerArena::Card.array('Qc Ac 8c 9c')
      combo = described_class.new(cards: cards)

      expect(combo.flush?).to eql(false)
    end

    it "return true when it's a flush" do
      cards = PokerArena::Card.array('7c Jc Tc 8c 9c')
      combo = described_class.new(cards: cards)

      expect(combo.flush?).to eql(true)
    end
  end

  describe '#straight?' do
    it "return false when it's not a straight" do
      cards = PokerArena::Card.array('7h Qc As 8c 9c')
      combo = described_class.new(cards: cards)

      expect(combo.straight?).to eql(false)
    end

    it "return true when it's a straight" do
      cards = PokerArena::Card.array('7h Jc Ts 8c 9c')
      combo = described_class.new(cards: cards)

      expect(combo.straight?).to eql(true)
    end
  end

  describe '#three_of_a_kind?' do
    it "return false when it's not a three of a kind combo" do
      cards = PokerArena::Card.array('7h Jc Ts 8c 9c')
      combo = described_class.new(cards: cards)

      expect(combo.three_of_a_kind?).to eql(false)
    end

    it "return true when it's a three of a kind combo" do
      cards = PokerArena::Card.array('8h Qc 8s 8c 9c')
      combo = described_class.new(cards: cards)

      expect(combo.three_of_a_kind?).to eql(true)
    end
  end

  describe '#two_pairs?' do
    it "return false when it's not a two pairs combo" do
      cards = PokerArena::Card.array('7h Jc Ts 8c 9c')
      combo = described_class.new(cards: cards)

      expect(combo.two_pairs?).to eql(false)
    end

    it "return true when it's a two pairs combo" do
      cards = PokerArena::Card.array('9h Qc 8s 8c 9c')
      combo = described_class.new(cards: cards)

      expect(combo.two_pairs?).to eql(true)
    end
  end

  describe '#pair?' do
    it "return false when it's not a pair combo" do
      cards = PokerArena::Card.array('7h Jc Ts 8c 9c')
      combo = described_class.new(cards: cards)

      expect(combo.pair?).to eql(false)
    end

    it "return true when it's a pair combo" do
      cards = PokerArena::Card.array('6h Qc 8s 8c 9c')
      combo = described_class.new(cards: cards)

      expect(combo.pair?).to eql(true)
    end
  end

  describe '#score' do
    it 'return 11_311_080_706 for 7h Qc As 8c 9c' do
      cards = PokerArena::Card.array('7h Qc As 8c 9c')
      combo = described_class.new(cards: cards)

      expect(combo.score).to eql(11_311_080_706)
    end

    it 'return 21_311_080_600 for 7h Qc As Ac 9c' do
      cards = PokerArena::Card.array('7h Qc As Ac 9c')
      combo = described_class.new(cards: cards)

      expect(combo.score).to eql(21_311_080_600)
    end

    it 'return 31_301_110_000 for 2d Qc As Ac 2c' do
      cards = PokerArena::Card.array('2d Qc As Ac 2c')
      combo = described_class.new(cards: cards)

      expect(combo.score).to eql(31_301_110_000)
    end

    it 'return 41_300_000_000 for Ad Qc As Ac 9c' do
      cards = PokerArena::Card.array('Ad Qc As Ac 9c')
      combo = described_class.new(cards: cards)

      expect(combo.score).to eql(41_300_000_000)
    end

    it 'return 50_400_000_000 for Ad 5s 4c 3c 2c' do
      cards = PokerArena::Card.array('Ad 5s 4c 3c 2c')
      combo = described_class.new(50_400_000_000)

      expect(combo.score).to eql(50_400_000_000)
    end

    it 'return 51_300_000_000 for Ad Kh Qc Js Tc' do
      cards = PokerArena::Card.array('Ad Kh Qc Js Tc')
      combo = described_class.new(cards: cards)

      expect(combo.score).to eql(51_300_000_000)
    end

    it 'return 61_110_090_201 for Qc Jc Tc 3c 2c' do
      cards = PokerArena::Card.array('Qc Jc Tc 3c 2c')
      combo = described_class.new(cards: cards)

      expect(combo.score).to eql(61_110_090_201)
    end

    it 'return 71_300_000_000 for Ad 2h As Ac 2c' do
      cards = PokerArena::Card.array('Ad 2h As Ac 2c')
      combo = described_class.new(cards: cards)

      expect(combo.score).to eql(71_300_000_000)
    end

    it 'return 81_300_000_000 for Ad Ah Qc As Ac' do
      cards = PokerArena::Card.array('Ad Ah Qc As Ac')
      combo = described_class.new(cards: cards)

      expect(combo.score).to eql(81_300_000_000)
    end

    it 'return 90_400_000_000 for Ac 5c 4c 3c 2c' do
      cards = PokerArena::Card.array('Ac 5c 4c 3c 2c')
      combo = described_class.new(cards: cards)

      expect(combo.score).to eql('(Straight flush)')
    end

    it 'return 100_000_000_000 for Ac Kc Qc Jc Tc' do
      cards = PokerArena::Card.array('Ac Kc Qc Jc Tc')
      combo = described_class.new(cards: cards)

      expect(combo.score).to eql(100_000_000_000)
    end
  end
end
