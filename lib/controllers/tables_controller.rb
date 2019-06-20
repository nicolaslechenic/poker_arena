module PokerArena
  class TablesController < Sinatra::Base
    def initialize(app, options)
      super(app)
      @tables_repository = options.fetch(:tables_repository)
      @players_repository = options.fetch(:players_repository)
    end

    get '/api/tables' do
      tables =
        @tables_repository.all.map do |table|
          TableSerializer.new(table: table).(
            without: %i[small_blind big_blind pot]
          )
        end

      json(tables: tables)
    end

    get '/api/tables/:name' do
      table = @tables_repository.find(params[:name].capitalize)

      serialized_players =
        table.seats.map.with_index do |player, index|
          seat = index + 1
          PlayerSerializer.new(player: player).(with: { seat: seat }, without: [:token])
        end

      serialized_matches =
        table.matches.map do |match|
          serialized_sets =
            match.sets.map do |set|
              serialized_games =
                set.games.map do |game|
                  serialized_actions =
                    game.actions.map do |action|
                      ActionSerializer.new(action: action).()
                    end
                  GameSerializer.new(game: game).(with: { actions: serialized_actions })
                end
              SetSerializer.new(set: set).(with: { games: serialized_games })
            end
          MatchSerializer.new(match: match).(with: { sets: serialized_sets })
        end

      output =
        TableSerializer.new(table: table).(with: {
          players: serialized_players,
          matches: serialized_matches
        })

      json(output)
    end

    post '/api/tables/:name/join' do
      params.merge!(JSON.parse(request.body.read))

      table = @tables_repository.find(params[:name].capitalize)
      player = @players_repository.find(params[:token])

      if table.seat_in(player)
        json(status: 200)
      else
        json(status: 400)
      end
    end

    post '/api/tables/:name/leave' do
      params.merge!(JSON.parse(request.body.read))

      table = @tables_repository.find(params[:name].capitalize)
      player = @players_repository.find(params[:token])

      if table.seat_out(player)
        json(status: 200)
      else
        json(status: 400)
      end
    end
  end
end
