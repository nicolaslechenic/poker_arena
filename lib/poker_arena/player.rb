module PokerArena
  class Player
    MAX_CARDS = 2

    include BCrypt
    include Mongoid::Document

    field :pseudo, type: String
    field :password, type: String

    validates :pseudo, presence: true
    validates :pseudo, uniqueness: true

    validates :password, presence: true
    validates_length_of :password, minimum: 8

    def self.create_with_password(params)
      new(
        pseudo: params['pseudo'],
        password: BCrypt::Password.create(params['password'])
      )
    end

    def cards
      @cards ||= []
    end

    def receive_card(card)
      raise RangeError unless cards.count < MAX_CARDS
      raise TypeError unless card.is_a?(Card)

      @cards << card
    end
  end
end
