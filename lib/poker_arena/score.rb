module PokerArena
  class Score
    class << self
      def call(combo)
        type = combo.type

        kicker =
          case type
          when 'royal_flush'
            '0000000000'
          when 'straight_flush'
            straight(combo.litterals, combo.cards)
          when 'four_of_a_kind'
            occured(combo, 4)
          when 'full_house'
            occured(combo, 3)
          when 'straight'
            straight(combo.litterals, combo.cards)
          when 'three_of_a_kind'
            occured(combo, 3)
          when 'two_pairs'
            pairs(combo)
          when 'pair'
            pairs(combo)
          else
            sorted(combo.cards)
          end

        new(
          type: (combo.type_index + 1).to_s.rjust(2, '0'),
          kicker: kicker
        ).call
      end

      def sorted(cards)
        Card.sorted(cards).reverse.map do |card|
          (card.value_index + 1).to_s.rjust(2, '0')
        end.join
      end

      private

      def occured(combo, times)
        cards =
          combo.cards_occured(times).map do |card_value|
            Card.x(card_value)
          end

        sorted(cards)
      end

      def straight(litterals, cards)
        return Card.x('5').value_score if (litterals - %w[A 5]).count == 3

        cards.max_by(&:score).value_score
      end

      def pairs(combo)
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
