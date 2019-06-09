module PokerArena
  class Player
    MAX_CARDS = 2

    class << self
      def generate
        new.token
      end

      def all
        ObjectSpace.each_object(self).to_a
      end

      def find(token)
        all.find { |player| player.token == token }
      end

      def valid_token?(token)
        find(token) ? true : false
      end
    end

    attr_reader :token, :cards
    def initialize
      @token = SecureRandom.hex(5)
      @cards = []
    end

    def receive_card(card)
      raise RangeError unless cards.count < MAX_CARDS
      raise TypeError unless card.is_a?(Card)

      cards << card
    end
  end
end
