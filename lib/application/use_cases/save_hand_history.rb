# frozen_string_literal: true

module PokerArena
  module Application
    module UseCases
      class SaveHandHistory
        def initialize(hand_histories_repository, tables_repository)
          @hand_histories_repository = hand_histories_repository
          @tables_repository = tables_repository
        end

        def call(table_name, skip_checks = false)
          table = @tables_repository.find(table_name)
          current_set = table.sets.last
          current_game = current_set&.games&.last

          return { status: 400, error: 'No active game found' } if current_game.nil?

          return save_hand_history(table, current_game) if skip_checks

          return { status: 400, error: 'Game is not completed' } unless current_game.status == :river
          return { status: 400, error: 'Round is not completed' } unless table.round_completed?

          save_hand_history(table, current_game)
        end

        private

        def save_hand_history(table, current_game)
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

          player_cards = {}
          table.players.each do |player|
            player_cards[player.pseudo] = player.cards.map(&:litteral) unless player.cards.empty?
          end

          hand_history = Domain::Entities::HandHistory.new(
            id: nil,
            table_name: table.name,
            players: players_data,
            actions: actions_data,
            board_cards: board_cards,
            pot: table.pot,
            winners: [],
            timestamp: Time.now,
            player_cards: player_cards
          )

          saved_history = @hand_histories_repository.persist(hand_history)

          {
            status: 200,
            message: 'Hand history saved successfully',
            hand_history_id: saved_history.id
          }
        end
      end
    end
  end
end
