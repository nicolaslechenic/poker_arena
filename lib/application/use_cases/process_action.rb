# frozen_string_literal: true

module PokerArena
  module Application
    module UseCases
      class ProcessAction
        def initialize(tables_repository, players_repository, hand_histories_repository = nil)
          @tables_repository = tables_repository
          @players_repository = players_repository
          @hand_histories_repository = hand_histories_repository
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

          save_hand_history_if_completed(table)

          @presenter.action_success
        end

        def save_hand_history_if_completed(table)
          return if @hand_histories_repository.nil?

          current_set = table.sets.last
          current_game = current_set&.games&.last
          
          return unless current_game
          return if hand_history_exists_for_game?(table, current_game)
          
          if should_save_hand_history?(table, current_game)
            save_hand_history(table, current_set, current_game)
          end
        end
        
        def should_save_hand_history?(table, current_game)
          is_river_completed?(current_game, table.players) ||
            only_one_active_player?(current_game) ||
            table.round_completed?
        end
        
        def is_river_completed?(current_game, players)
          current_game.status == :river && all_players_acted_in_river?(current_game, players)
        end
        
        def only_one_active_player?(current_game)
          active_players_count(current_game) <= 1
        end

        def all_players_acted_in_river?(game, players)
          active_players = players.reject do |player|
            game.actions.any? { |a| a.player == player && a.type == :fold }
          end

          river_actions = game.actions.select { |a| a.game_status == :river }
          river_players = river_actions.map(&:player).uniq

          active_players.all? { |player| river_players.include?(player) }
        end

        def active_players_count(game)
          all_players = game.actions.map(&:player).uniq

          folded_players = 
            game.actions.select { |a| a.type == :fold }.map(&:player).uniq

          all_players.size - folded_players.size
        end

        def hand_history_exists_for_game?(table, game)
          return false if @hand_histories_repository.nil?

          @hand_histories_repository.all.any? do |history|
            history.table_name == table.name &&
              history.actions.size == game.actions.size
          end
        end

        def save_hand_history(table, _current_set, current_game)
          players_data = table.players.map do |player|
            {
              pseudo: player.pseudo,
              position: table.players.index(player),
              initial_stack: player.cash.stack + player.cash.stakes
            }
          end

          actions_data = current_game.actions.map do |action|
            {
              player_position: table.players.index(action.player),
              player_pseudo: action.player.pseudo,
              type: action.type,
              value: action.value,
              game_status: current_game.status
            }
          end

          board_cards = {
            flop: table.board.flop,
            turn: table.board.turn,
            river: table.board.river
          }

          hand_history = Domain::Entities::HandHistory.new(
            id: nil,
            table_name: table.name,
            players: players_data,
            actions: actions_data,
            board_cards: board_cards,
            pot: table.pot,
            winners: [],
            timestamp: Time.now
          )

          @hand_histories_repository.persist(hand_history)
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
