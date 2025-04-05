# frozen_string_literal: true

module PokerArena
  class ActionProcessor
    def initialize(table)
      @table = table
    end

    def process(player, action_type, value = 0)
      return false if @table.sets.empty?
      return false if player != @table.current_player

      current_set = @table.sets.last
      current_game = current_set.games.last

      if player.all_in? && !%i[check fold].include?(action_type)
        action_type = :check
        value = 0
      end

      action = create_action(player, action_type, value)
      current_game.add_action(action)

      process_betting_action(player, action_type, value, action) if %i[bet call raise].include?(action_type)

      @table.advance_game_status if @table.round_completed?

      true
    end

    private

    def create_action(player, action_type, value)
      Action.new(
        player: player,
        type: action_type,
        value: value
      )
    end

    def process_betting_action(player, action_type, value, action)
      actual_amount = player.cash.stack_to_stakes(value)

      if actual_amount < value
        player.all_in = true
        action.value = actual_amount
      end

      if player.cash.amount.zero?
        player.all_in = true
      end

      @table.pot += actual_amount
    end
  end
end
