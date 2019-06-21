require 'spec_helper'

RSpec.describe PokerArena::Hand do
  it 'return return six combos for six cards in hand' do
    six_cards = PokerArena::Card.array('Ad 5s 6h 7c Tc 2s')
    hand = described_class.new(cards: six_cards)

    expect(hand.combos.count).to eql(6)
  end

  describe '#>' do
    it 'return true with best hand' do
      hero_cards = PokerArena::Card.array('2c 7d Qd Ac 8d 9d 3d')
      hero_hand = described_class.new(cards: hero_cards)

      vilain_cards = PokerArena::Card.array('2d 7h Qc As 8c 9c 3c')
      vilain_hand = described_class.new(cards: vilain_cards)

      expect(hero_hand > vilain_hand).to be_truthy
    end

    it 'return false same hand' do
      hero_cards = PokerArena::Card.array('2c 7s Qd Ac 8d 9d 3d')
      hero_hand = described_class.new(cards: hero_cards)

      vilain_cards = PokerArena::Card.array('2d 7h Qc As 8c 9c 3c')
      vilain_hand = described_class.new(cards: vilain_cards)

      expect(hero_hand > vilain_hand).to be_falsy
    end
  end

  describe '#<' do
    it 'return true with best hand' do
      hero_cards = PokerArena::Card.array('2c 7s Qd Ac 8d 9d 3d')
      hero_hand = described_class.new(cards: hero_cards)

      vilain_cards = PokerArena::Card.array('2d 7c Qc As 8c 9c 3c')
      vilain_hand = described_class.new(cards: vilain_cards)

      expect(hero_hand < vilain_hand).to be_truthy
    end

    it 'return false same hand' do
      hero_cards = PokerArena::Card.array('2c 7s Qd Ac 8d 9d 3d')
      hero_hand = described_class.new(cards: hero_cards)

      vilain_cards = PokerArena::Card.array('2d 7h Qc As 8c 9c 3c')
      vilain_hand = described_class.new(cards: vilain_cards)

      expect(hero_hand > vilain_hand).to be_falsy
    end
  end

  describe '#==' do
    it 'return false with best hand' do
      hero_cards = PokerArena::Card.array('2c 7d Qd Ac 8d 9d 3d')
      hero_hand = described_class.new(cards: hero_cards)

      vilain_cards = PokerArena::Card.array('2d 7s Qc As 8c 9c 3c')
      vilain_hand = described_class.new(cards: vilain_cards)

      expect(hero_hand == vilain_hand).to be_falsy
    end

    it 'return true with same hand' do
      hero_cards = PokerArena::Card.array('2c 7s Qd Ac 8d 9d 3d')
      hero_hand = described_class.new(cards: hero_cards)

      vilain_cards = PokerArena::Card.array('2d 7h Qc As 8c 9c 3c')
      vilain_hand = described_class.new(cards: vilain_cards)

      expect(hero_hand == vilain_hand).to be_truthy
    end
  end

  describe '#max' do
    it 'return all cards for hand with five cards or less' do
      four_cards = PokerArena::Card.array('5s 6h 7c Ad')
      four_cards_hand = described_class.new(cards: four_cards)

      five_cards = PokerArena::Card.array('5s 6h 7c 8d Ad')
      five_cards_hand = described_class.new(cards: five_cards)

      expect(four_cards_hand.max).to eql(four_cards)
      expect(five_cards_hand.max).to eql(five_cards)
    end
  end

  describe '#type' do
    it 'return (High card) for 2d 7h Qc As 8c 9c 3c' do
      cards = PokerArena::Card.array('2d 7h Qc As 8c 9c 3c')
      hand = described_class.new(cards: cards)

      expect(hand.type).to eql('(High card)')
    end

    it 'return (Pair) for 2d 7h Qc As Ac 9c 3c' do
      cards = PokerArena::Card.array('2d 7h Qc As Ac 9c 3c')
      hand = described_class.new(cards: cards)

      expect(hand.type).to eql('(Pair)')
    end

    it 'return (Two pairs) for 2d 7h Qc As Ac 9c 2c' do
      cards = PokerArena::Card.array('2d 7h Qc As Ac 9c 2c')
      hand = described_class.new(cards: cards)

      expect(hand.type).to eql('(Two pairs)')
    end

    it 'return (Three of a kind) for Ad 7h Qc As Ac 9c 2c' do
      cards = PokerArena::Card.array('Ad 7h Qc As Ac 9c 3c')
      hand = described_class.new(cards: cards)

      expect(hand.type).to eql('(Three of a kind)')
    end

    it 'return (Straight) for Ad 7h Qc 5s 4c 3c 2c' do
      cards = PokerArena::Card.array('Ad 7h Qc 5s 4c 3c 2c')
      hand = described_class.new(cards: cards)

      expect(hand.type).to eql('(Straight)')
    end

    it 'return (Straight) for Ad Kh Qc Js Tc 3c 2c' do
      cards = PokerArena::Card.array('Ad Kh Qc Js Tc 3c 2c')
      hand = described_class.new(cards: cards)

      expect(hand.type).to eql('(Straight)')
    end

    it 'return (Flush) for Ad 3h Qc Jc Tc 3c 2c' do
      cards = PokerArena::Card.array('Ad 3h Qc Jc Tc 3c 2c')
      hand = described_class.new(cards: cards)

      expect(hand.type).to eql('(Flush)')
    end

    it 'return (Full house) for Ad 2h Qc As Ac 9c 2c' do
      cards = PokerArena::Card.array('Ad 2h Qc As Ac 9c 2c')
      hand = described_class.new(cards: cards)

      expect(hand.type).to eql('(Full house)')
    end

    it 'return (Four of a kind) for Ad Ah Qc As Ac 9c 2c' do
      cards = PokerArena::Card.array('Ad Ah Qc As Ac 9c 2c')
      hand = described_class.new(cards: cards)

      expect(hand.type).to eql('(Four of a kind)')
    end

    it 'return (Straight flush) for Ac 7h Qc 5c 4c 3c 2c' do
      cards = PokerArena::Card.array('Ac 7h Qc 5c 4c 3c 2c')
      hand = described_class.new(cards: cards)

      expect(hand.type).to eql('(Straight flush)')
    end

    it 'return (Royal flush) for Ac Kc Qc Jc Tc 3d 2c' do
      cards = PokerArena::Card.array('Ac Kc Qc Jc Tc 3d 2c')
      hand = described_class.new(cards: cards)

      expect(hand.type).to eql('(Royal flush)')
    end
  end
end
