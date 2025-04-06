# frozen_string_literal: true

module PokerArena
  module Application
    module UseCases
      class GetGameState
        def initialize(tables_repository, players_repository)
          @tables_repository = tables_repository
          @players_repository = players_repository
          @game_service = Domain::Services::GameService.new
          @presenter = Interfaces::Presenters::GamePresenter.new
        end

        def call(table_name, player_token)
          table = @tables_repository.find(table_name)
          player = @players_repository.find(player_token)
          current_set = table.sets.last
          current_game = current_set&.games&.last

          return @presenter.waiting_state if current_game.nil?

          game_data = @presenter.game_state(table, player, current_set, current_game, @game_service,
                                            @players_repository)

          @presenter.active_state(game_data)
        end
      end
    end
  end
end
