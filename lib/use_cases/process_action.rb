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
        table = @tables_repository.find(table_name)
        player = @players_repository.find(player_token)

        return @presenter.error('Invalid action type') unless Action::TYPES.include?(action_type.to_sym)

        result = table.process_action(player, action_type.to_sym, value.to_f)
        return @presenter.error('Not your turn') unless result

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
