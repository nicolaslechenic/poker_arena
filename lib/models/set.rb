module PokerArena
  class Set
    STATUSES = %i[in_progress finished].freeze

    attr_reader :games, :button
    def initialize(button:)
      @games = []
      @button = button
    end

    def add_game
      @games << Game.new(type: Game.next_type(@games.last&.type))
    end
  end
end
