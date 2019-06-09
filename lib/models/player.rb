module PokerArena
  class Player < Sequel::Model(:players)
    MAX_CARDS = 2
    PSEUDOS =
      %w[Wallee Eve Ava Sonny Teddy R2D2 T800 Bishop Weebo Gerty].freeze

    class << self
      def generate
        available_pseudos = PSEUDOS - select_map(:pseudo)
        pseudo = available_pseudos.sample
        password = SecureRandom.hex(5)

        create(
          pseudo: pseudo,
          password: BCrypt::Password.create(password)
        )

        { pseudo: pseudo, password: password }
      end

      def login(params)
        player = find_by_pseudo(params['pseudo'])
        if player.password == params['password']
          give_token
        else
          redirect_to home_url
        end
      end
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
