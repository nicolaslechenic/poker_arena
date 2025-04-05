# frozen_string_literal: true

module PokerArena
  module Application
    module UseCases
      class ProcessAction
        def initialize(tables_repository, players_repository)
          @tables_repository = tables_repository
          @players_repository = players_repository
          @game_service = Domain::Services::GameService.new
          @game_progression_service = Domain::Services::GameProgressionService.new
          @presenter = Interfaces::Presenters::GamePresenter.new
        end

        def call(table_name, player_token, action_type, value)
          table = @tables_repository.find(table_name)
          player = @players_repository.find(player_token)

          unless Domain::Entities::Action::TYPES.include?(action_type.to_sym)
            return @presenter.error('Invalid action type')
          end

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
end
