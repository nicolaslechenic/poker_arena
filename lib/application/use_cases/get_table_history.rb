# frozen_string_literal: true

module PokerArena
  module Application
    module UseCases
      class GetTableHistory
        def initialize(hand_histories_repository, players_repository)
          @hand_histories_repository = hand_histories_repository
          @players_repository = players_repository
        end

        def call(table_name, player_token = nil)
          histories = @hand_histories_repository.find_by_table(table_name)

          if histories.empty?
            return {
              status: 200,
              message: "No hand histories found for table #{table_name}"
            }
          end

          player = player_token ? find_player(player_token) : nil

          {
            status: 200,
            table_name => {
              sets: format_histories(histories, player)
            }
          }
        rescue KeyError => e
          {
            status: 404,
            error: e.message
          }
        end

        private

        def find_player(token)
          @players_repository.find(token)
        rescue KeyError
          nil
        end

        def format_histories(histories, current_player)
          histories_by_set = {}

          histories.each do |history|
            histories_by_set["##{history.id}"] = {
              positions: format_positions(history),
              dealer: determine_dealer_position(history),
              games: format_games(history, current_player)
            }
          end

          histories_by_set
        end

        def format_positions(history)
          positions = {}

          history.players.each do |player|
            positions[player[:position].to_s] = player[:pseudo]
          end

          positions
        end

        def determine_dealer_position(_history)
          # TODO: Temporary assignation of dealer position
          0
        end

        # TODO: to many responsibility BEURK!!!
        def format_games(history, current_player)
          games = []
          rounds = %i[blinds preflop flop turn river showdown]

          pot = 0
          player_stacks = {}

          history.players.each do |player|
            player_stacks[player[:pseudo]] = player[:initial_stack]
          end

          # TODO: Beurk, iterate over select into each block...
          rounds.each do |round|
            round_actions =
              if round == :blinds
                history.actions.select do |action|
                  action[:type] == :bet && %i[blinds preflop].include?(action[:game_status])
                end.first(2)
              else
                round == :showdown ? [] : history.actions_by_street(round)
              end

            next if round_actions.empty? && round != :showdown

            formatted_actions = []

            round_actions.each do |action|
              player_pseudo = action[:player_pseudo]
              action_type = action[:type]
              action_value = action[:value]

              player_stacks[player_pseudo] -= action_value if %i[bet call raise].include?(action_type)

              pot += action_value if %i[bet call raise].include?(action_type)

              show_cards = should_show_cards?(current_player, player_pseudo, round == :showdown)

              formatted_action = {
                pseudo: player_pseudo,
                stack: player_stacks[player_pseudo],
                action: action_type.to_s,
                value: action_value,
                cards: show_cards ? get_player_cards(history, player_pseudo) : %w[xX xX],
                pot: pot
              }

              formatted_actions << formatted_action
            end

            if round == :showdown && has_showdown?(history)
              active_players = get_active_players(history)

              active_players.each do |player_pseudo|
                formatted_actions << {
                  pseudo: player_pseudo,
                  stack: player_stacks[player_pseudo],
                  action: 'showdown',
                  value: 0,
                  cards: get_player_cards(history, player_pseudo),
                  pot: pot
                }
              end
            end

            next if formatted_actions.empty?

            games << {
              actions: formatted_actions,
              board: get_board_for_round(history, round),
              round: round.to_s
            }
          end

          games
        end

        def should_show_cards?(current_player, player_pseudo, is_showdown)
          return true if is_showdown
          return false unless current_player

          current_player.pseudo == player_pseudo
        end

        def get_player_cards(history, player_pseudo)
          history.player_cards[player_pseudo]
        end

        def get_board_for_round(history, round)
          case round
          when :blinds, :preflop
            []
          when :flop
            history.board_cards[:flop] || []
          when :turn
            (history.board_cards[:flop] || []) + [history.board_cards[:turn]].compact
          when :river, :showdown
            (history.board_cards[:flop] || []) + [history.board_cards[:turn], history.board_cards[:river]].compact
          end
        end

        def has_showdown?(history)
          # TODO: to improve
          # For now, we'll assume it did if there are river actions
          !history.river_actions.empty?
        end

        def get_active_players(history)
          all_players = history.players.map { |p| p[:pseudo] }

          folded_players = history.actions.select { |a| a[:type] == :fold }.map { |a| a[:player_pseudo] }

          all_players - folded_players
        end
      end
    end
  end
end
