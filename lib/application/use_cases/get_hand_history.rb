# frozen_string_literal: true

module PokerArena
  module Application
    module UseCases
      class GetHandHistory
        def initialize(hand_histories_repository)
          @hand_histories_repository = hand_histories_repository
        end

        def call(id, player_token = nil)
          hand_history = @hand_histories_repository.find(id)
          serialized_history =
            Interfaces::Serializers::HandHistorySerializer.new(
              hand_history: hand_history
            ).call(player_token: player_token)

          {
            status: 200,
            hand_history: serialized_history
          }
        rescue KeyError => e
          {
            status: 404,
            error: e.message
          }
        end

        def get_table_histories(table_name, player_token = nil)
          histories = @hand_histories_repository.find_by_table(table_name)
          serialized_histories = histories.map do |history|
            Interfaces::Serializers::HandHistorySerializer.new(hand_history: history).call(player_token: player_token)
          end

          {
            status: 200,
            hand_histories: serialized_histories
          }
        end
      end
    end
  end
end
