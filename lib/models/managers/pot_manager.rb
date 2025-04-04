# frozen_string_literal: true

module PokerArena
  class PotManager
    def initialize(table)
      @table = table
    end

    def distribute_pot(current_game)
      active_players = @table.players.reject { |p| player_folded?(p, current_game) }

      if active_players.count == 1
        award_pot_to_winner(active_players.first)
      else
        winner = find_best_hand_player(active_players)
        award_pot_to_winner(winner)
      end
    end

    private

    def player_folded?(player, game)
      game.actions.select { |a| a.player == player }.any? { |a| a.type == :fold }
    end

    def find_best_hand_player(active_players)
      best_hand = nil
      winner = nil

      active_players.each do |player|
        all_cards = player.cards + @table.board.cards
        hand = Hand.new(cards: all_cards)

        if best_hand.nil? || hand > best_hand
          best_hand = hand
          winner = player
        end
      end

      winner
    end

    def award_pot_to_winner(winner)
      winner.cash.amount += @table.pot
      @table.pot = 0
    end
  end
end
