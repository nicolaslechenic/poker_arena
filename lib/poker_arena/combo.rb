module PokerArena
  class Combo
    TYPES =
      %w[
        high_card pair two_pairs three_of_a_kind
        straight flush full_house four_of_a_kind
        straight_flush royal_flush
      ].freeze

    class << self
      def array(cards)
        return [new(cards: cards)] if cards.count <= 5

        cards.combination(5).to_a.map do |five_cards|
          new(cards: five_cards)
        end
      end

      def straights
        Card::VALUES.each_cons(5).to_a << %w[2 3 4 5 A]
      end
    end

    attr_reader :cards
    def initialize(cards:)
      raise ArgumentError unless valid?(cards)

      @cards = cards
    end

    def score
      Score.call(self)
    end

    def type
      @type ||=
        TYPES.reverse_each do |type|
          return type if send("#{type}?")
        end
    end

    def type_index
      TYPES.index(type)
    end

    # The combos methods belows give an answer to the question
    # do you have at least method_name? but it's not necessary your
    # best combination !

    def royal_flush?
      (litterals == %w[T J Q K A]) && flush?
    end

    def straight_flush?
      straight? && flush?
    end

    def four_of_a_kind?
      cards_occured(4).any?
    end

    def full_house?
      three_of_a_kind? && pair?
    end

    def flush?
      cards.map(&:suit).uniq.count == 1 && cards.count == 5
    end

    def straight?
      self.class.straights.include?(litterals)
    end

    def three_of_a_kind?
      cards_occured(3).any?
    end

    def two_pairs?
      cards_occured(2).count == 2
    end

    def pair?
      cards_occured(2).any?
    end

    # You have at least high card !
    def high_card?
      true
    end

    # @return [Array] sorted values
    #   > ['5', '6', '7', 'T', 'J']
    def litterals
      ordered_cards = cards.sort_by(&:score)

      ordered_cards.map(&:value)
    end

    # Sorted occurence by value (higher to lower occurences)
    #
    # @return [Hash] example for combo: As Ac 2d 2c 3h
    #   < occurences
    #   > { 'A' => 2, '2' => 2, '3' => 1 }
    def occurences
      h = Hash.new(0)

      cards.sort_by(&:score).reverse_each do |card|
        h[card.value] += 1
      end

      h.sort_by { |_, value| -value }.to_h
    end

    # Get values of x times occured cards
    #
    # @return [Array] example for combo: As Ac 2d 2c 3h
    #   < cards_occured(2)
    #   > ['A', '2']
    def cards_occured(times)
      occurences.select { |_, value| value == times }.keys
    end

    private

    def valid?(cards)
      cards.count <= 5
    end
  end
end
