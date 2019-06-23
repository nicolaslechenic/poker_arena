module PokerArena
  class Set
    STATUSES = %i[in_progress finished].freeze

    attr_reader :games, :showdown, :players, :button_position
    def initialize(players:)
      @games = []
      @players = players
      @showdown = nil
      @button_position = 0
    end

    def add_game(game)
      raise TypeError unless game.is_a?(Game)
      @games << game
    end
  end
end
