# frozen_string_literal: true

module PokerArena
  module Domain
    module Entities
      class Player
        MAX_CARDS = 2

        attr_reader :token, :pseudo, :stack, :cash
        attr_accessor :cards, :all_in

        def initialize(pseudo:, cash: Cash.new)
          @cards = []
          @pseudo = pseudo
          @cash = cash
          @all_in = false
        end

        def receive_card(card)
          raise RangeError unless cards.count < MAX_CARDS
          raise TypeError unless card.is_a?(Card)

          cards << card
        end

        def all_in?
          @all_in
        end
      end
    end
  end
end
