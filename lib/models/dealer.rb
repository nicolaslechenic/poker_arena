module PokerArena
  class Dealer
    attr_reader :deck
    def initialize(deck: Deck.new)
      @deck = deck
    end

    def deal(receiver)
      card = deck.delete_card

      begin
        receiver.receive_card(card)
      rescue RangeError
        deck.restore_card(card)
      end
    end
  end
end
