module PokerArena
  class Cash
    INIT_BANKROLL = 10_000

    attr_reader :bankroll, :stack, :stakes
    def initialize(bankroll: INIT_BANKROLL)
      @bankroll = INIT_BANKROLL
      # stack is a part of bankroll reserved to the current set
      @stack = 0
      # stakes is a part of stack reserved to the current game
      @stakes = 0
    end

    def rebuy_max
      bankroll_to_stack(bankroll_to_stack_max_amount)
    end

    def bankroll_to_stack(amount)
      return if broke?
      return if stack >= Table::LIMIT

      @bankroll -= amount
      @stack += amount
    end

    def stack_to_stakes(amount)
      raise ArgumentError unless stack >= amount

      @stack -= amount
      @stakes += amount
    end

    def delete_stakes
      stakes_value = stakes
      @stakes = 0

      stakes_value
    end

    def credit_stack(amount)
      raise TypeError unless amount.is_a?(Float)
      @stack += amount
    end

    def stack_to_bankroll
      @bankroll += stack
      @stack = 0
    end

    def broke?
      bankroll.zero?
    end

    private

    def bankroll_to_stack_max_amount
      max_rebuy = (Table::LIMIT - stack)
      (max_rebuy > bankroll) ? bankroll : max_rebuy
    end
  end
end
