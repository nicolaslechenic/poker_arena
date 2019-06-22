module PokerArena
  class Action
    TYPES = %i[fold check call bet raise].freeze

    attr_reader :player, :type, :value
    def initialize(player:, type:, value:)
      @player = player
      @type = type
      @value = value
    end
  end
end
