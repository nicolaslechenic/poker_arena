# frozen_string_literal: true

module PokerArena
  class Game
    STATUSES = %i[blinds preflop flop turn river].freeze

    attr_accessor :status
    attr_reader :actions

    def initialize(status:)
      @status = status
      @actions = []
    end

    def add_action(action)
      raise TypeError unless action.is_a?(Action)

      @actions << action
    end

    def current_bet
      return 0 if actions.empty?

      selected_actions = 
        actions.select { |action| %i[bet raise].include?(action.type) }

      selected_actions
        .map(&:value)
        .max || 0
    end

    def player_actions(player)
      actions.select { |a| a.player == player }
    end

    def last_action
      actions.last
    end

    def active_players
      players = actions.map(&:player).uniq
      players.reject do |player|
        player_actions(player).any? { |a| a.type == :fold }
      end
    end
  end
end
