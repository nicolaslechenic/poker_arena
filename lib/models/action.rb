module PokerArena
  class Action
    TYPES = %i[small_blind big_blind fold check call bet raise all_in].freeze

    attr_reader :pseudo, :type, :value
    def initialize(pseudo:, type:, value:)
      @pseudo = pseudo
      @type   = type
      @value  = value
    end
  end
end
