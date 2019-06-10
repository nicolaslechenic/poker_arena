module PokerArena
  class PlayersController < Sinatra::Base
    def initialize(app, options)
      super(app)
      @players_repository = options.fetch(:players_repository)
    end

    get '/api/players/generate' do
      player = Player.new
      @players_repository.persist(player)

      json(player: PlayerSerializer.new(player: player).())
    end
  end
end
