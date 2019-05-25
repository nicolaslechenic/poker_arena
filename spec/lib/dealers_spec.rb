require 'spec_helper'

RSpec.describe PokerArena::Dealer do
  describe '#deal' do
    before(:each) do
      @dealer = described_class.new(deck: PokerArena::Deck.new)
      @player = PokerArena::Player.new
    end

    it 'remove dealed card' do
      count_cards = @dealer.deck.remaining_cards.count
      @dealer.deal(@player)

      expect(@dealer.deck.remaining_cards.count).to eql(count_cards - 1)
      expect(@player.cards.count).to eql(1)
    end

    it 'restore card when receiver can not reveive' do
      @dealer.deal(@player)
      @dealer.deal(@player)
      count_cards = @dealer.deck.remaining_cards.count
      @dealer.deal(@player)

      expect(@dealer.deck.remaining_cards.count).to eql(count_cards)
      expect(@player.cards.count).to eql(2)
    end
  end
end
