# frozen_string_literal: true

module PokerArena
  class BlindManager
    def initialize(table)
      @table = table
    end

    def collect_blinds(game, current_set)
      button_pos = current_set.button_position
      small_blind_pos = (button_pos + 1) % @table.players.count
      big_blind_pos = (button_pos + 2) % @table.players.count

      collect_small_blind(game, small_blind_pos)
      collect_big_blind(game, big_blind_pos)
    end

    private

    def collect_small_blind(game, small_blind_pos)
      sb_player = @table.players[small_blind_pos]
      sb_action = Action.new(
        player: sb_player,
        type: :bet,
        value: @table.small_blind
      )
      game.add_action(sb_action)
      actual_sb = sb_player.cash.stack_to_stakes(@table.small_blind)

      if actual_sb < @table.small_blind
        sb_player.all_in = true
        sb_action.value = actual_sb
      end

      if sb_player.cash.amount.zero?
        sb_player.all_in = true
      end

      @table.pot += actual_sb
    end

    def collect_big_blind(game, big_blind_pos)
      bb_player = @table.players[big_blind_pos]
      bb_action = Action.new(
        player: bb_player,
        type: :bet,
        value: @table.big_blind
      )
      game.add_action(bb_action)
      actual_bb = bb_player.cash.stack_to_stakes(@table.big_blind)

      if actual_bb < @table.big_blind
        bb_player.all_in = true
        bb_action.value = actual_bb
      end

      if bb_player.cash.amount.zero?
        bb_player.all_in = true
      end

      @table.pot += actual_bb
    end
  end
end
