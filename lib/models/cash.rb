# frozen_string_literal: true

module PokerArena
  class Cash
    INIT_BANKROLL = 10_000

    attr_reader :stakes
    attr_accessor :stack, :bankroll

    def initialize(bankroll: INIT_BANKROLL)
      @bankroll = INIT_BANKROLL
      @stack = 0
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
      actual_amount = [stack, amount].min

      @stack -= actual_amount
      @stakes += actual_amount

      actual_amount
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

    def amount
      stack
    end

    def amount=(value)
      self.stack = value
    end

    private

    def bankroll_to_stack_max_amount
      max_rebuy = (Table::LIMIT - stack)
      max_rebuy > bankroll ? bankroll : max_rebuy
    end
  end
end
