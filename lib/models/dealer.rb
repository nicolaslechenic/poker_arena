# frozen_string_literal: true

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

    def deal_cards_to_players(players)
      players.each do |player|
        player.cards = []
        2.times { deal(player) }
      end
    end
  end
end
