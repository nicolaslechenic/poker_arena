module PokerArena
  class Match
    attr_accessor :id, :sets, :players, :status
    def initialize(players:)
      raise ArgumentError unless players.count == 2

      @id = SecureRandom.hex(5)
      @sets = []
      @players = players
      @status = :in_progress
    end

    def finish
      self.status = :finished
    end

    def play
      # TODO
    end

    def add_set
      Set.new(button: button_position)
    end

    def button_position
      sets.even? ? 1 : 2
    end
  end
end
