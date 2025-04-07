# frozen_string_literal: true

module PokerArena
  module Domain
    module Entities
      class HandHistory
        attr_reader :id, :table_name, :players, :actions, :board_cards, :pot, :timestamp, :winners, :player_cards

        def initialize(id:, table_name:, players:, actions:, board_cards:, pot:, winners: [], timestamp: Time.now,
                       player_cards: {})
          @id = id
          @table_name = table_name
          @players = players
          @actions = actions
          @board_cards = board_cards
          @pot = pot
          @winners = winners
          @timestamp = timestamp
          @player_cards = player_cards
        end

        def player_actions(player_position)
          actions.select { |action| action[:player_position] == player_position }
        end

        def actions_by_street(street)
          actions.select { |action| action[:game_status] == street }
        end

        def preflop_actions
          actions_by_street(:preflop)
        end

        def flop_actions
          actions_by_street(:flop)
        end

        def turn_actions
          actions_by_street(:turn)
        end

        def river_actions
          actions_by_street(:river)
        end

        def player_at_position(position)
          players.find { |player| player[:position] == position }
        end

        def ==(other)
          return false unless other.is_a?(HandHistory)

          id == other.id &&
            table_name == other.table_name &&
            players == other.players &&
            actions == other.actions &&
            board_cards == other.board_cards &&
            pot == other.pot &&
            winners == other.winners &&
            timestamp.to_s == other.timestamp.to_s
        end
      end
    end
  end
end
