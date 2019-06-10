module PokerArena
  class PlayerSerializer < ::PokerArena::ApplicationSerializer
    attr_reader :player
    def initialize(player:)
      @player = player
    end

    private
    # Have to be flat
    def full_json
      @full_json ||=
        {
          pseudo: player.pseudo,
          token: player.token
        }
    end
  end
end
