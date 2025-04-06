# frozen_string_literal: true

require 'json'
require 'fileutils'
require 'securerandom'

module PokerArena
  module Infrastructure
    module Repositories
      class PlayersRepository
        DEFAULT_TOKEN_SIZE = 5
        DATA_DIR = File.join(Dir.pwd, 'data')

        def initialize(file_path = nil, token_size: DEFAULT_TOKEN_SIZE)
          @file_path = file_path || File.join(DATA_DIR, 'players.json')
          @serializer = Persistence::PlayerSerializer.new
          @store = Persistence::JsonStore.new(@file_path)
          @token_size = token_size
        end

        def all
          @store.all.map { |data| @serializer.deserialize(data) }
        end

        def find(token)
          data = @store.find(token.to_s)
          raise KeyError, "Player with token #{token} not found" unless data

          @serializer.deserialize(data)
        end

        def persist(player)
          if player.token && @store.find(player.token)
            existing_player = find(player.token)
            if existing_player.pseudo != player.pseudo
              raise ArgumentError,
                    "Another player with token '#{player.token}' exists."
            end

            serialized_data = @serializer.serialize(player)
            @store.save(player.token, serialized_data)
            return true
          end

          serialized_data = @serializer.serialize(player)
          @store.save(player.token, serialized_data)

          true
        end

        def delete(token)
          data = @store.delete(token.to_s)
          data ? @serializer.deserialize(data) : nil
        end

        def clear
          @store.clear
        end
      end
    end
  end
end
