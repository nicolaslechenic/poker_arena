# frozen_string_literal: true

module PokerArena
  module Infrastructure
    module Persistence
      class PlayerSerializer
        def serialize(player)
          {
            'token' => player.token,
            'pseudo' => player.pseudo,
            'cash' => serialize_cash(player.cash),
            'cards' => serialize_cards(player.cards),
            'all_in' => player.all_in
          }
        end

        def deserialize(data)
          player = Domain::Entities::Player.new(
            pseudo: data['pseudo']
          )

          player.instance_variable_set('@token', data['token'])
          player.instance_variable_set('@cash', deserialize_cash(data['cash']))
          player.cards = deserialize_cards(data['cards'])
          player.all_in = data['all_in']

          player
        end

        private

        def serialize_cash(cash)
          {
            'bankroll' => cash.bankroll,
            'stack' => cash.stack,
            'stakes' => cash.stakes
          }
        end

        def deserialize_cash(cash_data)
          cash = Domain::Entities::Cash.new(bankroll: cash_data['bankroll'])
          cash.stack = cash_data['stack']
          cash.instance_variable_set('@stakes', cash_data['stakes'])
          cash
        end

        def serialize_cards(cards)
          cards.map(&:litteral)
        end

        def deserialize_cards(card_litterals)
          card_litterals.map { |litteral| Domain::Entities::Card.new(litteral) }
        end
      end
    end
  end
end
