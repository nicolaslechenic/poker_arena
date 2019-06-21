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
        camel_types.reverse_each do |type|
          return new(cards: cards) if type == 'HighCard'
          combo = Object.const_get("PokerArena::#{type}Combo")

          return combo.new(cards: cards) if combo.available?(cards)
        end
      end

      def array(cards)
        return [new(cards: cards)] if cards.count <= 5

        cards.combination(5).to_a.map do |five_cards|
          Combo.for(cards: five_cards)
        end
      end

      def straights
        Card::VALUES.reverse.each_cons(5).to_a << %w[A 5 4 3 2]
      end

      # You have at least high card !
      def high_card?(cards)
        return false if cards.empty?
        true
      end

      def camel_types
        TYPES.map do |type|
          type.split('_').collect(&:capitalize).join
        end
      end
    end

    attr_reader :cards
    def initialize(cards:)
      validate(cards)
      @cards = Card.sorted(cards).reverse
    end

    def score
      [type_index, kicker_score]
    end

    def type_index
      TYPES.index(type)
    end
    alias type_score type_index

    def kicker_cards
      cards
    end

    def kicker_score
      Score.new(cards: kicker_cards).()
    end

    # @return [Array] sorted values
    #   > ['5', '6', '7', 'T', 'J']
    def litteral_values
      cards.map(&:litteral_value).reverse
    end

    def type
      camel_type =
        if self.class.name.split('::').last == 'Combo'
          'HighCard'
        else
          self.class.name.split('::').last[0..-6]
        end

      @type ||= TYPES[self.class.camel_types.index(camel_type)]
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

      cards.each do |card|
        h[card.value] += 1
      end

      h.sort_by { |_, value| -value }.to_h
    end

    # Auto generate verification boolean type methods
    #  high_card? pair? two_pairs? ...
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
