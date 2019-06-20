module PokerArena
  class ActionsRepository
    def initialize
      @actions = {}
    end

    def all
      @actions.values
    end

    def find(pseudo)
      @actions.fetch(pseudo)
    end

    def persist(action)
      if @actions.key?(action.pseudo)
        if find(action.pseudo) != action
          raise ArgumentError, "Another action with id '#{action.pseudo}' exists."
        else
          return true
        end
      end

      @actions[action.pseudo] = action

      true
    end
  end
end
