module PokerArena
  class Score
    class << self
      def sorted(cards)
        Card.sorted(cards).reverse.map do |card|
          (card.value_index + 1).to_s.rjust(2, '0')
        end.join
      end

      # @return [String] for cards that occure x times
      #   Example for 2 times with cards below:
      #   < Ax Ax Qx Qx 2x
      #   > 1311
      def kicker_occured(combo, times)
        combo.cards_occured(times).map do |card_value|
          Card.x(card_value).value_score
        end.join
      end

      # @return [String] highest straight card score
      #   Example for Ax 2x 3x 4x 5x
      #   > 04 (refer to 05x)
      def kicker_straight(litterals, cards)
        return Card.x('5').value_score if (litterals - %w[A 5]).count == 3

        cards.max_by(&:score).value_score
      end

      # @return [String]
      #   < Ax Ax Qx Qx 2x
      #   > 131101
      def kicker_pairs(combo)
        combo.occurences.map do |value, _|
          Card.x(value).value_score
        end.join
      end
    end

    attr_reader :type, :kicker
    def initialize(type:, kicker:)
      raise ArgumentError unless valid?(type, kicker)

      @type = type
      @kicker = uniformize(kicker)
    end

    def call
      (type + kicker).to_i
    end

    private

    def valid?(type, kicker)
      kicker.is_a?(String) && kicker.size >= 2 && type.is_a?(String)
    end

    def uniformize(kicker)
      kicker.ljust(10, '0')
    end
  end
end
