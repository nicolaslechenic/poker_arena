# frozen_string_literal: true

module PokerArena
  module Infrastructure
    module Persistence
      class HandHistorySerializer
        def serialize(hand_history)
          {
            'id' => hand_history.id,
            'table_name' => hand_history.table_name,
            'players' => serialize_players(hand_history.players),
            'actions' => serialize_actions(hand_history.actions),
            'board_cards' => serialize_board_cards(hand_history.board_cards),
            'pot' => hand_history.pot,
            'winners' => serialize_winners(hand_history.winners),
            'timestamp' => hand_history.timestamp.to_s
          }
        end

        def deserialize(data)
          Domain::Entities::HandHistory.new(
            id: data['id'],
            table_name: data['table_name'],
            players: deserialize_players(data['players']),
            actions: deserialize_actions(data['actions']),
            board_cards: deserialize_board_cards(data['board_cards']),
            pot: data['pot'],
            winners: deserialize_winners(data['winners']),
            timestamp: Time.parse(data['timestamp'])
          )
        end

        private

        def serialize_players(players)
          players.map do |player|
            {
              'pseudo' => player[:pseudo],
              'position' => player[:position],
              'initial_stack' => player[:initial_stack]
            }
          end
        end

        def deserialize_players(players)
          players.map do |player|
            {
              pseudo: player['pseudo'],
              position: player['position'],
              initial_stack: player['initial_stack']
            }
          end
        end

        def serialize_actions(actions)
          actions.map do |action|
            {
              'player_position' => action[:player_position],
              'player_pseudo' => action[:player_pseudo],
              'type' => action[:type].to_s,
              'value' => action[:value],
              'game_status' => action[:game_status].to_s
            }
          end
        end

        def deserialize_actions(actions)
          actions.map do |action|
            {
              player_position: action['player_position'],
              player_pseudo: action['player_pseudo'],
              type: action['type'].to_sym,
              value: action['value'],
              game_status: action['game_status'].to_sym
            }
          end
        end

        def serialize_board_cards(board_cards)
          {
            'flop' => board_cards[:flop],
            'turn' => board_cards[:turn],
            'river' => board_cards[:river]
          }
        end

        def deserialize_board_cards(board_cards)
          {
            flop: board_cards['flop'],
            turn: board_cards['turn'],
            river: board_cards['river']
          }
        end

        def serialize_winners(winners)
          winners.map do |winner|
            {
              'player_position' => winner[:player_position],
              'amount_won' => winner[:amount_won]
            }
          end
        end

        def deserialize_winners(winners)
          winners.map do |winner|
            {
              player_position: winner['player_position'],
              amount_won: winner['amount_won']
            }
          end
        end
      end
    end
  end
end
