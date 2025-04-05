# frozen_string_literal: true

module PokerArena
  module Domain
    module Entities
      class FlushCombo < ::PokerArena::Domain::Entities::Combo
        class << self
          def available?(cards)
            cards.map(&:suit).uniq.count == 1 &&
              cards.count == 5
          end
        end
      end
    end
  end
end
