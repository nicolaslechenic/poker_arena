# frozen_string_literal: true

module PokerArena
  module Services
    class GameProgressionService
      def advance_game_status(table, current_set, current_game)
        status_handlers = {
          preflop: ->(table, game) { advance_to_flop(table, game) },
          flop: ->(table, game) { advance_to_turn(table, game) },
          turn: ->(table, game) { advance_to_river(table, game) },
          river: ->(table, _game) { end_hand(table, current_set) }
        }

        handler = status_handlers[current_game.status]
        handler&.call(table, current_game)
      end

      def advance_to_flop(table, game)
        game.status = :flop
        deal_flop(table)
      end

      def deal_flop(table)
        3.times { table.dealer.deal(table.board) }
      end

      def advance_to_turn(table, game)
        game.status = :turn
        deal_turn(table)
      end

      def deal_turn(table)
        table.dealer.deal(table.board)
      end

      def advance_to_river(table, game)
        game.status = :river
        deal_river(table)
      end

      def deal_river(table)
        table.dealer.deal(table.board)
      end

      def end_hand(table, set)
        determine_winner(table)
        move_button(table, set)
      end

      def move_button(table, set)
        set.button_position = (set.button_position + 1) % table.players.count
      end

      def determine_winner(table)
        game_service = GameService.new
        current_game = table.sets.last.games.last
        active_players = game_service.active_players(table, current_game)

        winner = 
          if active_players.count == 1
            active_players.first
          else
            game_service.find_best_hand_player(active_players, table.board)
          end

        award_pot_to_winner(table, winner)
      end

      def award_pot_to_winner(table, winner)
        winner.cash.amount += table.pot
        table.pot = 0
      end
    end
  end
end
