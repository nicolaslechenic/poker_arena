# frozen_string_literal: true

module PokerArena
  class BoardSerializer < ::PokerArena::ApplicationSerializer
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
