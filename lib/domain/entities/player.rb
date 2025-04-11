# frozen_string_literal: true

module PokerArena
  module Domain
    module Entities
      class Player
        MAX_CARDS = 2

        class << self
          def build(**data)
            player =
              new(
                pseudo: data[:pseudo],
                cash: data[:cash]
              )

            player.token = data[:token]
            player.all_in = data[:all_in]
            player.cards = data[:cards]

            player
          end
        end

        attr_reader :pseudo, :stack, :cash
        attr_accessor :cards, :all_in, :token, :cash

        def initialize(pseudo:, cash: Cash.new)
          @cards = []
          @pseudo = pseudo
          @cash = cash
          @all_in = false
          @token = SecureRandom.hex(10)
        end

        def receive_card(card)
          raise RangeError unless cards.count < MAX_CARDS
          raise TypeError unless card.is_a?(Card)

          cards << card
        end

        def all_in?
          @all_in
        end

        def ==(other)
          return false unless other.is_a?(Player)

          pseudo == other.pseudo && token == other.token
        end
      end
    end
  end
end
