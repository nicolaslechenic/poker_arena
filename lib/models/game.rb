module PokerArena
  class Game
    TYPES = %i[preflop flop turn river].freeze

    class << self
      def next_type(current_type)
        return TYPES[0] if current_type.nil?
        return TYPES[0] if (TYPES.index(current_type) + 1) == TYPES.count

        TYPES[(TYPES.index(current_type) + 1)]
      end
    end

    attr_reader :actions
    def initialize(type:)
      @type = type
      @actions = []
    end

    def fold
      @actions << Action.new(
        type: :fold,

      )
    end


    def post_small
      
    end

    def available_actions
      # List available actions
      # if first

      # @actions.empty? ?
    end

    def raise_value

    end

    def finished?
      # verify if game is finished
    end
  end
end
