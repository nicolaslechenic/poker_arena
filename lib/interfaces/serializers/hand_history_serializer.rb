# frozen_string_literal: true

module PokerArena
  module Interfaces
    module Serializers
      class HandHistorySerializer < ApplicationSerializer
        def initialize(hand_history:)
          @hand_history = hand_history
        end

        def call(options = {})
          without = options.fetch(:without, [])
          with = options.fetch(:with, {})
          player_token = options.fetch(:player_token, nil)

          result = {
            id: @hand_history.id,
            table_name: @hand_history.table_name,
            timestamp: @hand_history.timestamp,
            pot: @hand_history.pot,
            players: @hand_history.players,
            actions: serialize_actions(@hand_history.actions),
            board_cards: @hand_history.board_cards,
            winners: @hand_history.winners,
            player_cards: serialize_player_cards(@hand_history.player_cards, player_token)
          }

          result.merge!(with)
          result.reject! { |key, _| without.include?(key) }

          result
        end

        private

        def serialize_actions(actions)
          {
            preflop: actions.select { |action| action[:game_status] == :preflop },
            flop: actions.select { |action| action[:game_status] == :flop },
            turn: actions.select { |action| action[:game_status] == :turn },
            river: actions.select { |action| action[:game_status] == :river }
          }
        end

        def serialize_player_cards(player_cards, player_token)
          return {} unless player_cards && player_token

          player_pseudo = find_player_pseudo(player_token)
          return {} unless player_pseudo

          filtered_cards = {}
          if player_cards[player_pseudo]
            filtered_cards[player_pseudo] =
              player_cards[player_pseudo]
          end

          filtered_cards
        end

        def find_player_pseudo(player_token)
          # We would look up the player's pseudo from the token
          # For now, we'll assume the token is the pseudo
          player_token
        end
      end
    end
  end
end
