module PokerArena
  class Score
    class << self
      def call(cards)
        cards.sort_by(&:score).reverse.map do |card|
          (Card::VALUES.index(card.value) + 1).to_s.rjust(2, '0')
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
