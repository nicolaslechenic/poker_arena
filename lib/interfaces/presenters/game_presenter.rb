# frozen_string_literal: true

module PokerArena
  module Interfaces
    module Presenters
      class GamePresenter
        def current_player_data(table, current_set, game_service)
          return {} if current_set.nil?

          current_pos = game_service.current_player_position(table, current_set)
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

        def players_data(table, current_player, players_repository)
          table.players.map do |player|
            player_infos = players_repository.find(player.token)
            data = {
              pseudo: player.pseudo,
              stack: player_infos.cash.stack,
              position: table.players.index(player)
            }

            data[:cards] = player.cards.map(&:litteral) if player == current_player

            data
          end
        end

        def game_state(table, current_player, current_set, current_game, game_service, players_repository)
          {
            status: current_game.status,
            pot: table.pot,
            current_player: current_player_data(table, current_set, game_service),
            board: board_data(table.board),
            players: players_data(table, current_player, players_repository)
          }
        end

        def waiting_state
          {
            status: 200,
            state: 'waiting',
            message: 'No game in progress'
          }
        end

        def active_state(game_data)
          {
            status: 200,
            state: 'active',
            game: game_data
          }
        end

        def action_success
          {
            status: 200,
            message: 'Action processed'
          }
        end

        def game_start_success
          {
            status: 200,
            message: 'Game started'
          }
        end

        def error(message, status = 400)
          {
            status: status,
            error: message
          }
        end
      end
    end
  end
end
