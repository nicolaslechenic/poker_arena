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

          result = {
            id: @hand_history.id,
            table_name: @hand_history.table_name,
            timestamp: @hand_history.timestamp,
            pot: @hand_history.pot,
            players: @hand_history.players,
            actions: serialize_actions(@hand_history.actions),
            board_cards: @hand_history.board_cards,
            winners: @hand_history.winners
          }

          result.merge!(with)
          result.reject! { |key, _| without.include?(key) }

          result
        end

        private

        def serialize_actions(actions)
          # Group actions by street for better organization
          {
            preflop: actions.select { |action| action[:game_status] == :preflop },
            flop: actions.select { |action| action[:game_status] == :flop },
            turn: actions.select { |action| action[:game_status] == :turn },
            river: actions.select { |action| action[:game_status] == :river }
          }
        end
      end
    end
  end
end
