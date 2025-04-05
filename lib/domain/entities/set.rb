# frozen_string_literal: true

module PokerArena
  module Domain
    module Entities
      class Set
        STATUSES = %i[in_progress finished].freeze

        attr_reader :games, :showdown, :players
        attr_accessor :button_position

        def initialize(players:)
          @games = []
          @players = players
          @showdown = nil
          @button_position = 0
        end

        def add_game(game)
          raise TypeError unless game.is_a?(Game)

          @games << game
        end

        def current_game
          games.last
        end

        def next_player_position(after_position)
          position = (after_position + 1) % players.count

          position = (position + 1) % players.count while current_game && player_folded?(players[position])

          position
        end

        def player_folded?(player)
          return false if current_game.nil?

          current_game.actions.select { |a| a.player == player }.any? { |a| a.type == :fold }
        end

        def player_to_act
          return nil if current_game.nil?

          if current_game.status == :preflop && current_game.actions.count <= 2
            return players[(button_position + 3) % players.count]
          end

          last_action = current_game.actions.last
          return players[button_position] if last_action.nil?

          last_pos = players.index(last_action.player)
          next_pos = next_player_position(last_pos)
          players[next_pos]
        end
      end
    end
  end
end
