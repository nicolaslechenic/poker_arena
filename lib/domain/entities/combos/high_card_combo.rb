# frozen_string_literal: true

module PokerArena
  module Domain
    module Entities
      class HighCardCombo < ::PokerArena::Domain::Entities::Combo
        class << self
          def available?(cards)
            return false if cards.empty?

            true
          end
        end
      end
    end
  end
end
