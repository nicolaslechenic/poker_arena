module PokerArena
  class Card
    VALUES  = %w[2 3 4 5 6 7 8 9 T J Q K A].freeze
    SUITS   = %w[diamond club heart spade].freeze

    class << self
      def all
        SUITS.map do |suit|
          VALUES.map do |value|
            new("#{value}#{suit[0]}")
          end
        end.flatten
      end

      def array(litterals)
        litterals.split.map do |litteral|
          new(litteral)
        end
      end

      def x(value)
        new("#{value}#{SUITS.sample[0]}")
      end
    end

    attr_reader :litteral, :value, :suit
    def initialize(litteral)
      raise ArgumentError unless valid?(litteral)

      @litteral = litteral
      @value    = find_value(litteral)
      @suit     = find_suit(litteral)
    end

    def score
      (value_score + suit_score).to_i
    end

    private

    def valid?(litteral)
      litteral.length == 2 &&
        VALUES.include?(litteral[0]) &&
        SUITS.map { |suit| suit[0] }.include?(litteral[1])
    end

    def find_value(litteral)
      litteral[0]
    end

    def find_suit(litteral)
      SUITS.find { |suit| suit[0] == litteral[1] }
    end

    def value_score
      (VALUES.index(value) + 1).to_s.rjust(2, '0')
    end

    def suit_score
      (SUITS.index(suit) + 1).to_s.rjust(2, '0')
    end
  end
end
