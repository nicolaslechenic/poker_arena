# frozen_string_literal: true

module PokerArena
  module Application
    module UseCases
      class GetTableState
        def initialize(tables_repository)
          @tables_repository = tables_repository
          @presenter = Interfaces::Presenters::GamePresenter.new
        end

        def call(table_name)
          table = @tables_repository.find(table_name)
          current_set = table.sets.last
          current_game = current_set&.games&.last

          return @presenter.waiting_state if current_game.nil?

          game_data = spectator_game_state(table, current_set, current_game)

          @presenter.active_state(game_data)
        end

        private

        def spectator_game_state(table, current_set, current_game)
          {
            status: current_game.status,
            pot: table.pot,
            current_player: current_player_data(table, current_set),
            board: board_data(table.board),
            players: spectator_players_data(table)
          }
        end

        def current_player_data(table, set)
          return {} if set.nil?

          game_service = Domain::Services::GameService.new
          current_pos = game_service.current_player_position(table, set)
          current = table.players[current_pos]

          {
            pseudo: current.pseudo,
            position: current_pos
          }
        end

        def board_data(board)
          {
            flop: board.flop,
            turn: board.turn,
            river: board.river
          }
        end

        def spectator_players_data(table)
          table.players.map do |p|
            {
              pseudo: p.pseudo,
              stack: p.cash.amount,
              position: table.players.index(p)
            }
          end
        end
      end
    end
  end
end
