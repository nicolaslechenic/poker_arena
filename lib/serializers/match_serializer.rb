module PokerArena
  class MatchSerializer < ::PokerArena::ApplicationSerializer
    attr_reader :match
    def initialize(match:)
      @match = match
    end

    private
    # Have to be flat
    def full_json
      @full_json ||=
        {
          id: match.id,
          status: match.status
        }
    end
  end
end
