module PokerArena
  class MatchesController < Sinatra::Base
    def initialize(app, options)
      super(app)
      @matches_repository = options.fetch(:matches_repository)
      @tables_repository  = options.fetch(:tables_repository)
      @players_repository = options.fetch(:players_repository)
    end

    get '/api/matches/create' do
      table = Table.new(tables_repository: @tables_repository)
      @tables_repository.persist(table)

      match = Match.new(table: table)
      @matches_repository.persist(match)

      json(match: match.id)
    end

    get '/api/matches/:id' do
      match =
        @matches_repository.find(params[:id])

      match.play

      serialized_players =
        match.table.seats.map.with_index do |player, index|
          seat = index + 1
          PlayerSerializer.new(player: player).(with: { seat: seat }, without: [:token])
        end

      serialized_sets =
        match.sets.map do |set|
          serialized_games =
            set.games.map do |game|
              GameSerializer.new(game: game).()
            end

          SetSerializer.new(set: set).(with: { games: serialized_games })
        end

      output =
        MatchSerializer.new(match: match).(with: {
          table: match.table.name,
          players: serialized_players,
          sets: serialized_sets
        })

      json(output)
    end

    post '/api/matches/:id/join' do
      params.merge!(JSON.parse(request.body.read))

      match = @matches_repository.find(params[:id])
      player = @players_repository.find(params[:token])

      if match.join(player)
        json(status: 200)
      else
        json(status: 400)
      end
    end

    post '/api/matches/:id/leave' do
      params.merge!(JSON.parse(request.body.read))

      match   = @matches_repository.find(params[:id])
      player  = @players_repository.find(params[:token])

      if match.leave(player)
        json(status: 200)
      else
        json(status: 400)
      end
    end
  end
end
