# frozen_string_literal: true

module PokerArena
  module UseCases
    class ProcessAction
      def initialize(tables_repository, players_repository)
        @tables_repository = tables_repository
        @players_repository = players_repository
        @game_service = Services::GameService.new
        @game_progression_service = Services::GameProgressionService.new
        @presenter = Presenters::GamePresenter.new
      end

      def call(table_name, player_token, action_type, value)
        table = @tables_repository.find(table_name.capitalize)
        player = @players_repository.find(player_token)
        current_set = table.sets.last

        return @presenter.error('Not your turn') unless current_player?(table, player, current_set)
        return @presenter.error('Invalid action type') unless Action::TYPES.include?(action_type.to_sym)

        current_game = current_set.games.last
        action = Action.new(
          player: player,
          type: action_type.to_sym,
          value: value.to_f
        )
        current_game.add_action(action)

        update_pot(table, action)

        if @game_service.round_completed?(table, current_set, current_game)
          @game_progression_service.advance_game_status(table, current_set, current_game)
        end

        @presenter.action_success
      end

      private

      def current_player?(table, player, current_set)
        return false if current_set.nil?

        current_player = @game_service.current_player_position(table, current_set)
        table.players[current_player] == player
      end

      def update_pot(table, action)
        case action.type
        when :bet, :call, :raise
          table.pot += action.value
        end
      end
    end
  end
end
