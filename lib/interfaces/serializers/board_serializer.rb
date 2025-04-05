# frozen_string_literal: true

module PokerArena
  module Interfaces
    module Serializers
      class BoardSerializer < ::PokerArena::Interfaces::Serializers::ApplicationSerializer
        attr_reader :board

        def initialize(board:)
          @board = board
        end

        private

        def full_json
          {
            flop: board.flop,
            turn: board.turn,
            river: board.river
          }
        end
      end
    end
  end
end
