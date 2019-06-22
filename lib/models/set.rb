module PokerArena
  class Set
    STATUSES = %i[in_progress finished].freeze

    attr_reader :games, :showdown
    def initialize
      @games = []
      @showdown = nil
    end

    def add_game(game)
      raise TypeError unless game.is_a?(PokerArena::Game)
      @games << game
    end
  end
end
