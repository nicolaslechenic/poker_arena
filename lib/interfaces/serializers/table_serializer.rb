# frozen_string_literal: true

module PokerArena
  module Interfaces
    module Serializers
      class TableSerializer < ::PokerArena::Interfaces::Serializers::ApplicationSerializer
        attr_reader :table

        def initialize(table:)
          @table = table
        end

        private

        # Have to be flat
        def full_json
          @full_json ||=
            {
              name: table.name,
              limit: table.limit,
              big_blind: table.big_blind,
              small_blind: table.small_blind,
              max_players: table.max_players,
              available_players: table.available_players,
              pot: table.pot
            }
        end
      end
    end
  end
end
