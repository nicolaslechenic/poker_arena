module PokerArena
  class TableSerializer < ::PokerArena::ApplicationSerializer
    attr_reader :table
    def initialize(table:)
      @table = table
    end

    private
    # Have to be flat
    def full_json
      @full_json ||=
        {
          name: table.name,
          limit: table.limit,
          big_blind: table.big_blind,
          small_blind: table.small_blind,
          max_players: table.max_players,
          available_seats: table.available_seats,
          pot: table.pot
        }
    end
  end
end
