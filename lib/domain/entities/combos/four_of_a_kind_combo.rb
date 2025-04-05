# frozen_string_literal: true

module PokerArena
  module Domain
    module Entities
      class FourOfAKindCombo < ::PokerArena::Domain::Entities::Combo
        class << self
          def available?(cards)
            new(cards: cards).cards_occured(4).any?
          end
        end

        def kicker_cards
          [Card.x(cards_occured(4).first)]
        end
      end
    end
  end
end
