# frozen_string_literal: true

module PokerArena
  module Infrastructure
    module Persistence
      class TableSerializer
        def serialize(table)
          {
            'name' => table.name,
            'limit' => table.limit,
            'big_blind' => table.big_blind,
            'small_blind' => table.small_blind,
            'max_players' => table.max_players,
            'pot' => table.pot,
            'players' => serialize_players(table.players),
            'board' => serialize_board(table.board),
            'sets' => serialize_sets(table.sets)
          }
        end

        def deserialize(data, tables_repository = nil)
          board = deserialize_board(data['board']) || Domain::Entities::Board.new
          dealer = Domain::Entities::Dealer.new

          table = Domain::Entities::Table.new(
            tables_repository: tables_repository,
            board: board,
            dealer: dealer
          )

          table.instance_variable_set('@name', data['name'])
          table.pot = data['pot'] || 0.0

          players = deserialize_players(data['players'] || [])
          table.instance_variable_set('@players', players)

          sets = deserialize_sets(data['sets'] || [], table, players)
          table.instance_variable_set('@sets', sets)

          # Ensure all services are properly initialized
          # These are already initialized in the Table constructor, so we don't need to set them again

          table
        end

        private

        def serialize_players(players)
          players.map do |player|
            {
              'token' => player.token,
              'pseudo' => player.pseudo
            }
          end
        end

        def deserialize_players(players_data)
          return [] unless players_data

          players_data.map do |player_data|
            player = Domain::Entities::Player.new(
              pseudo: player_data['pseudo']
            )
            player.instance_variable_set('@token', player_data['token'])
            player
          end
        end

        def serialize_board(board)
          return nil unless board

          {
            'flop' => board.flop,
            'turn' => board.turn,
            'river' => board.river
          }
        end

        def deserialize_board(board_data)
          return nil unless board_data

          board = Domain::Entities::Board.new
          board.instance_variable_set('@flop', board_data['flop'])
          board.instance_variable_set('@turn', board_data['turn'])
          board.instance_variable_set('@river', board_data['river'])
          board
        end

        def serialize_sets(sets)
          return [] unless sets

          sets.map do |set|
            {
              'games' => serialize_games(set.games)
            }
          end
        end

        def deserialize_sets(sets_data, table, players)
          return [] unless sets_data

          sets_data.map do |set_data|
            set = Domain::Entities::Set.new(players: table.players)
            games = deserialize_games(set_data['games'], set, players)
            set.instance_variable_set('@games', games)
            set
          end
        end

        def serialize_games(games)
          return [] unless games

          games.map do |game|
            {
              'status' => game.status.to_s,
              'actions' => serialize_actions(game.actions)
            }
          end
        end

        def deserialize_games(games_data, _set, players)
          return [] unless games_data

          games_data.map do |game_data|
            game_data['status'].to_sym
            game = Domain::Entities::Game.new(status: game_data['status'].to_sym)
            actions = deserialize_actions(game_data['actions'], game, players)
            game.actions = actions
            game
          end
        end

        def serialize_actions(actions)
          return [] unless actions

          actions.map do |action|
            {
              'player_token' => action.player.token,
              'type' => action.type.to_s,
              'value' => action.value
            }
          end
        end

        def deserialize_actions(actions_data, game, players)
          return [] unless actions_data

          actions_data.map do |action_data|
            player = players.find { |p| p.token == action_data['player_token'] }
            next unless player

            Domain::Entities::Action.new(
              player: player,
              type: action_data['type'].to_sym,
              value: action_data['value'],
              game_status: game.status
            )
          end.compact
        end
      end
    end
  end
end
