module PokerArena
  class Match
    attr_reader :id, :table, :sets
    def initialize(table:)
      @id = SecureRandom.hex(5)
      @table = table
      @sets = []
    end

    def join(player)
      table.seat_in(player)
    end

    def leave(player)
      table.seat_out(player)
    end

    def status
      table.full? ? :ingame : :waiting_for_player
    end
  end
end
