module PokerArena
  class BoardSerializer < ::PokerArena::ApplicationSerializer
    attr_reader :board
    def initialize(board:)
      @board = board
    end

    private
    # Have to be flat
    def full_json
      {
        flop: board.flop,
        turn: board.turn,
        river: board.river
      }
    end
  end
end
