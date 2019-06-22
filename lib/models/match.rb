module PokerArena
  class Match
    attr_reader :id, :players, :sets
    def initialize(players:)
      raise ArgumentError unless players.count == 2

      @id = SecureRandom.hex(5)
      @players = players
      @sets = []
    end

    def add_set(set)
      raise TypeError unless set.is_a?(PokerArena::Set)

      @sets << set
    end
  end
end
