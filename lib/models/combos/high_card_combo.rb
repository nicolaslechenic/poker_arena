# frozen_string_literal: true

module PokerArena
  class HighCardCombo < ::PokerArena::Combo
    class << self
      def available?(cards)
        return false if cards.empty?

        true
      end
    end
  end
end
