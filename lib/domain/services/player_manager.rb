# frozen_string_literal: true

module PokerArena
  module Domain
    module Services
      class PlayerManager
        def initialize(table)
          @table = table
        end

        def seat_in!(player)
          raise RangeError if @table.full?
          raise TypeError unless player.is_a?(Entities::Player)
          raise IndexError if @table.players.any? { |p| p.equal?(player) }

          min_required = @table.big_blind * 10
          raise StandardError, "Not enough bankroll (minimum #{min_required})" if player.cash.bankroll < min_required

          target_stack = @table.big_blind * 100
          transfer_amount = [target_stack, player.cash.bankroll].min

          player.cash.bankroll_to_stack(transfer_amount)

          @table.players << player
          @table.sets << Entities::Set.new(players: @table.players) if @table.full?
        end

        def seat_out(player)
          @table.players.delete(player)
        end
      end
    end
  end
end
