# frozen_string_literal: true

module PokerArena
  module Domain
    module Entities
      class RoyalFlushCombo < ::PokerArena::Domain::Entities::Combo
        class << self
          def available?(cards)
            (cards.map(&:litteral_value) == %w[A K Q J T]) &&
              PokerArena::Domain::Entities::FlushCombo.available?(cards)
          end
        end

        def kicker_cards
          []
        end
      end
    end
  end
end
