module PokerArena
  class Deck
    attr_reader :remaining_cards
    def initialize
      @remaining_cards = Card.all
    end

    # @return [Object] deteted card
    def delete_card
      card = remaining_cards.sample
      remaining_cards.delete(card)

      card
    end

    def restore_card(card)
      remaining_cards << card
    end
  end
end
