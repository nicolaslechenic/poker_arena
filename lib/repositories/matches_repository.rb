module PokerArena
  class MatchesRepository
    def initialize
      @matches = {}
    end

    def all
      @matches.values
    end

    def find(id)
      @matches.fetch(id)
    end

    def persist(match)
      if @matches.key?(match.id)
        if find(match.id) != match
          raise ArgumentError, "Another match with id '#{match.id}' exists."
        else
          return true
        end
      end

      @matches[match.id] = match

      true
    end
  end
end
