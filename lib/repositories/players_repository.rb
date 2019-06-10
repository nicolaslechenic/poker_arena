module PokerArena
  class PlayersRepository
    DEFAULT_TOKEN_SIZE = 5

    def initialize(token_size: DEFAULT_TOKEN_SIZE)
      @players = {}
      @token_size = token_size
    end

    def all
      @players.values
    end

    def find(token)
      @players.fetch(token)
    end

    def persist(player)
      if @players.key?(player.token)
        if find(player.token) != player
          raise ArgumentError, "Another player with token '#{player.token}' exists."
        else
          return true
        end
      end

      token = unused_token
      player.instance_variable_set(:@token, token)
      @players[token] = player

      true
    end

    private

    def unused_token
      iteration = 0

      loop do
        token = SecureRandom.hex(@token_size)
        return token unless @players.key?(token)

        iteration += 1
        raise "Can't find a new and unused token" if iteration > 5
      end
    end
  end
end
