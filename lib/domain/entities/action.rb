# frozen_string_literal: true

module PokerArena
  module Domain
    module Entities
      class Action
        TYPES = %i[fold check call bet raise].freeze

        attr_reader :player, :type
        attr_accessor :value

        def initialize(player:, type:, value:)
          @player = player
          @type = type
          @value = value
        end
      end
    end
  end
end
