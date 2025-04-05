# frozen_string_literal: true

module PokerArena
  module Interfaces
    module Serializers
      class PlayerSerializer < ::PokerArena::Interfaces::Serializers::ApplicationSerializer
        attr_reader :player

        def initialize(player:)
          @player = player
        end

        private

        # Have to be flat
        def full_json
          @full_json ||=
            {
              pseudo: player.pseudo,
              token: player.token,
              bankroll: player.cash.bankroll
            }
        end
      end
    end
  end
end
