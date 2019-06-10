module PokerArena
  class PlayersController < Sinatra::Base
    def initialize(app, options)
      super(app)
      @players_repository = options.fetch(:players_repository)
    end

    get '/api/players' do
      players =
        @players_repository.all.map do |player|
          PlayerSerializer.new(player: player).(without: [:token])
        end

      json(players: players)
    end

    post '/api/players' do
      params.merge!(JSON.parse(request.body.read))

      player = Player.new(pseudo: params[:pseudo])
      @players_repository.persist(player)

      if @players_repository.persist(player)
        json(status: 200)
      else
        json(status: 400)
      end
    end
  end
end
