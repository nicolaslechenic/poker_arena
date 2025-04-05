# frozen_string_literal: true

module PokerArena
  module Domain
    module Entities
      class StraightFlushCombo < ::PokerArena::Domain::Entities::Combo
        class << self
          def available?(cards)
            PokerArena::Domain::Entities::StraightCombo.available?(cards) &&
              PokerArena::Domain::Entities::FlushCombo.available?(cards)
          end
        end

        def kicker_cards
          return [Card.x('5')] if (litteral_values - %w[A 5]).count == 3

          [cards.first]
        end
      end
    end
  end
end
