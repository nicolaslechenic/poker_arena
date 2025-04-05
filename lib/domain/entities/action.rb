# frozen_string_literal: true

module PokerArena
  module Domain
    module Entities
      class Action
        TYPES = %i[fold check call bet raise].freeze

        attr_reader :player, :type, :game_status
        attr_accessor :value

        def initialize(player:, type:, value:, game_status: nil)
          @player = player
          @type = type
          @value = value
          @game_status = game_status
        end
      end
    end
  end
end
