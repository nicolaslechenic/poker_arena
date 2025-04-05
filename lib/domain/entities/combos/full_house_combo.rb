# frozen_string_literal: true

module PokerArena
  module Domain
    module Entities
      class FullHouseCombo < ::PokerArena::Domain::Entities::Combo
        class << self
          def available?(cards)
            PokerArena::Domain::Entities::ThreeOfAKindCombo.available?(cards) &&
              PokerArena::Domain::Entities::PairCombo.available?(cards)
          end
        end

        def kicker_cards
          [Card.x(cards_occured(3).first)]
        end
      end
    end
  end
end
