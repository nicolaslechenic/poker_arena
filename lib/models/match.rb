module PokerArena
  class Match
    attr_reader :id, :players, :sets
    def initialize(players:)
      raise ArgumentError unless players.count == 2

      @id = SecureRandom.hex(5)
      @players = players
      @sets = []
    end
  end
end
