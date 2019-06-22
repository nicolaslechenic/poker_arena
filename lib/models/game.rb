module PokerArena
  class Game
    STATUSES = %i[blinds preflop flop turn river].freeze

    attr_reader :status, :actions
    def initialize(status:)
      @status = status
      @actions = []
    end

    def add_action(action)
      raise TypeError unless action.is_a?(PokerArena::Action)

      @actions << action
    end
  end
end
