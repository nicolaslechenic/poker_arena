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

    # Depends on combo best type and kickers
    # Final score join type score and uniformized kicker score
    #
    # Royal flush:
    #   - type score: 10
    #   - kicker score: no kickers (0)
    #   - uniformized kicker score 0_000_000_000
    #   - score: 10 and 0_000_000_000 => 100_000_000_000
    #   => 0_000_000_000
    #
    # Straight flush:
    #   - type score: 9
    #   - kicker score:
    #       depends on highest straight card
    #       3d4d5d6d7d => 7d => 06pts
    #   - uniformized kicker score 0_600_000_000
    #   - score: 9 and 0_600_000_000 => 90_600_000_000
    #   => score_for_best_card
    #
    # Four of a kind:
    #   - type score: 8
    #   - kicker score:
    #       depends Four of kind card
    #       AxAxAxAxX => Ax => 13pts
    #   - uniformized kicker score 1_300_000_000
    #   - score: 8 and 1_300_000_000 => 81_300_000_000
    #   => score_for_occurence(4)
    #
    # Full house:
    #   - type score: 7
    #   - kicker score:
    #       depends Three of kind card
    #       QxQxQx2x2x => Qx => 11pts
    #   - uniformized kicker score 1_100_000_000
    #   - score: 7 and 1_100_000_000 => 71_100_000_000
    #   => score_for_occurence(3)
    #
    # Flush:
    #   - type score: 6
    #   - kicker score:
    #       depends all cards
    #       Ad9d7d6d5d => 13pts 08pts 06pts 05pts 04pts =>  1_308_060_504
    #   - uniformized kicker score 1_308_060_504
    #   - score: 6 and 1_308_060_504 => 61_308_060_504
    #   => kicker: Score.(cards)
    #
    # Straight:
    #   - type score: 5
    #   - kicker score:
    #       depends the best card
    #       Td9h8c7c6c => Td => 08pts
    #   - uniformized kicker score 0_900_000_000
    #   - score: 5 and 0_900_000_000 => 50_900_000_000
    #   => score_for_best_card
    #
    # Three of a kind:
    #   - type score: 4
    #   - kicker score:
    #       depends Three of kind card
    #       QxQxQx3x2x => Qx => 11pts
    #   - uniformized kicker score 1_100_000_000
    #   - score: 4 and 1_100_000_000 => 41_100_000_000
    #   => score_for_occurence(3)
    #
    # Two pairs:
    #   - type score: 3
    #   - kicker score:
    #       join pairs and count card
    #       AdAd5d5d7d => 13pts 04pts 05pts =>  130_406
    #   - uniformized kicker score 1_304_060_000
    #   - score: 3 and 1_304_060_000 => 31_304_060_000
    #
    # Pair:
    #   - type score: 2
    #   - kicker score:
    #       join pair and count card
    #       AdAd7d5h4h => 13pts 06pts 04pts 03pts =>  13_060_403
    #   - uniformized kicker score 1_306_040_300
    #   - score: 2 and 1_306_040_300 => 21_306_040_300
    #
    # High card:
    #   - type score: 1
    #       depends all cards
    #       Ac9s7h6d5c => 13pts 08pts 06pts 05pts 04pts =>  1_308_060_504
    #   - uniformized kicker score 1_308_060_504
    #   - score: 1 and 1_308_060_504 => 11_308_060_504
    #   => Score.(cards)
    #
    def score
      kicker =
        case type
        when 'royal_flush'
          '0000000000'
        when 'straight_flush'
          score_for_straight
        when 'four_of_a_kind'
          score_for_occured(4)
        when 'full_house'
          score_for_occured(3)
        when 'straight'
          score_for_straight
        when 'three_of_a_kind'
          score_for_occured(3)
        when 'two_pairs'
          score_for_pairs
        when 'pair'
          score_for_pairs
        else
          Score.call(cards)
        end

      Score.new(
        type: (TYPES.index(type) + 1).to_s.rjust(2, '0'),
        kicker: kicker
      ).call
    end

    def type
      @type ||=
        TYPES.reverse_each do |type|
          return type if send("#{type}?")
        end
    end

    # The combos methods belows give an answer to the question
    # do you have at least method_name? but it's not necessary your
    # best combination !

    def royal_flush?
      (litterals_values == %w[T J Q K A]) && flush?
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
      self.class.straights.include?(litterals_values)
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

    private

    def valid?(cards)
      cards.count <= 5
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

    # Get total score of x times occured cards
    def score_for_occured(times)
      cards =
        cards_occured(times).map do |card_value|
          Card.x(card_value)
        end

      Score.call(cards)
    end

    def score_for_pairs
      occurences.map do |value, _|
        Card.x(value).value_score
      end.join
    end

    # @return [Array] sorted values
    #   > ['5', '6', '7', 'T', 'J']
    def litterals_values
      ordered_cards = cards.sort_by(&:score)

      ordered_cards.map(&:value)
    end

    def score_for_straight
      top_card = cards.max_by(&:score)
      return top_card.value_score if top_card.value != 'A' || litterals_values[-2] != '5'

      Card.x(litterals_values[-2]).value_score
    end
  end
end
