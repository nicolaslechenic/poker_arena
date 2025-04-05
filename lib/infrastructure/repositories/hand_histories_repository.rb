# frozen_string_literal: true

require 'json'
require 'fileutils'

module PokerArena
  module Infrastructure
    module Repositories
      class HandHistoriesRepository
        DATA_DIR = File.join(Dir.pwd, 'data')

        def initialize(file_path = nil)
          @file_path = file_path || File.join(DATA_DIR, 'hand_histories.json')
          @serializer = Persistence::HandHistorySerializer.new
          @store = Persistence::JsonStore.new(@file_path)
          @next_id = find_next_id
        end

        def all
          @store.all.map { |data| @serializer.deserialize(data) }
        end

        def find(id)
          data = @store.find(id.to_s)
          raise KeyError, "Hand history with ID #{id} not found" unless data

          @serializer.deserialize(data)
        end

        def find_by_table(table_name)
          all.select { |history| history.table_name == table_name }
        end

        def persist(hand_history)
          if hand_history.id.nil?
            id = @next_id.to_s
            @next_id += 1

            # Create a new hand history with the assigned ID
            new_hand_history = Domain::Entities::HandHistory.new(
              id: id,
              table_name: hand_history.table_name,
              players: hand_history.players,
              actions: hand_history.actions,
              board_cards: hand_history.board_cards,
              pot: hand_history.pot,
              winners: hand_history.winners,
              timestamp: hand_history.timestamp
            )

            serialized_data = @serializer.serialize(new_hand_history)
            @store.save(id, serialized_data)
            new_hand_history
          else
            serialized_data = @serializer.serialize(hand_history)
            @store.save(hand_history.id.to_s, serialized_data)
            hand_history
          end
        end

        def delete(id)
          data = @store.delete(id.to_s)
          data ? @serializer.deserialize(data) : nil
        end

        def clear
          @store.clear
          @next_id = 1
        end

        private

        def find_next_id
          ids = @store.all.map { |data| data['id'].to_i }
          ids.empty? ? 1 : ids.max + 1
        end
      end
    end
  end
end
