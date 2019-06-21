module PokerArena
  class Combo
    TYPES =
      %w[
        high_card pair two_pairs three_of_a_kind
        straight flush full_house four_of_a_kind
        straight_flush royal_flush
      ].freeze

    class << self
      def for(cards:)
        cards_type = type_for(cards)

        return new(cards: cards) if cards_type == 'high_card'

        prefix = cards_type.split('_').collect(&:capitalize).join
        combo_type = Object.const_get("PokerArena::#{prefix}Combo")

        combo_type.new(cards: cards)
      end

      def type_for(cards)
        TYPES.reverse_each do |type|
          return type if send("#{type}?", cards)
        end
      end

      # @return [Array] sorted values
      #   > ['5', '6', '7', 'T', 'J']
      def litterals(cards)
        ordered_cards = cards.sort_by(&:score)

        ordered_cards.map(&:value)
      end

      def array(cards)
        return [new(cards: cards)] if cards.count <= 5

        cards.combination(5).to_a.map do |five_cards|
          Combo.for(cards: five_cards)
        end
      end

      def straights
        Card::VALUES.each_cons(5).to_a << %w[2 3 4 5 A]
      end

      # The combos methods belows give an answer to the question
      # do you have at least method_name? but it's not necessary your
      # best combination !

      def royal_flush?(cards)
        (litterals(cards) == %w[T J Q K A]) && flush?(cards)
      end

      def straight_flush?(cards)
        straight?(cards) && flush?(cards)
      end

      def four_of_a_kind?(cards)
        new(cards: cards).cards_occured(4).any?
      end

      def full_house?(cards)
        three_of_a_kind?(cards) && pair?(cards)
      end

      def flush?(cards)
        cards.map(&:suit).uniq.count == 1 &&
          cards.count == 5
      end

      def straight?(cards)
        straights.include?(litterals(cards))
      end

      def three_of_a_kind?(cards)
        new(cards: cards).cards_occured(3).any?
      end

      def two_pairs?(cards)
        new(cards: cards).cards_occured(2).count == 2
      end

      def pair?(cards)
        new(cards: cards).cards_occured(2).any?
      end

      # You have at least high card !
      def high_card?(cards)
        return false if cards.empty?
        true
      end
    end

    attr_reader :cards
    def initialize(cards:)
      validate(cards)
      @cards = Card.sorted(cards)
    end

    def score
      [type_index, kicker_score]
    end

    def type_index
      TYPES.index(type)
    end
    alias type_score type_index

    def kicker_score
      cards.reverse.map do |card|
        (card.value_index + 1).to_s.rjust(2, '0')
      end.join.to_i
    end

    # @return [Array] sorted values
    #   > ['5', '6', '7', 'T', 'J']
    def litterals
      self.class.litterals(cards)
    end

    def type
      @type ||= self.class.type_for(cards)
    end

    # Get values of x times occured cards
    #
    # @return [Array] example for cards: As Ac 2d 2c 3h
    #   < cards_occured(2)
    #   > ['A', '2']
    def cards_occured(times)
      occurences.select { |_, value| value == times }.keys
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

    TYPES.each do |method|
      define_method("#{method}?") do
        return true if method == 'high_card'

        prefix = method.split('_').collect(&:capitalize).join
        self.class.name == "PokerArena::#{prefix}Combo"
      end
    end

    private

    def validate(cards)
      raise RangeError unless cards.count <= 5
    end
  end
end
