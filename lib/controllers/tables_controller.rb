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

    get '/api/tables/create' do
      current_table = Table.new(tables_repository: @tables_repository)

      if @tables_repository.persist(current_table)
        output =
          TableSerializer.new(table: current_table).()

        json(status: 200, table: output)
      else
        json(status: 400)
      end
    end

    get '/api/tables/:name' do
      serialized_players =
        table.players.map do |player|
          PlayerSerializer.new(player: player).(without: [:token])
        end

      output =
        TableSerializer.new(table: table).(with: { players: serialized_players })

      json(output)
    end

    post '/api/tables/:name/join' do
      merge_params
      if table.seat_in(player)
        json(status: 200)
      else
        json(status: 400)
      end
    end

     post '/api/tables/:name/leave' do
      merge_params
      if table.seat_out(player)
        json(status: 200)
      else
        json(status: 400)
      end
    end

    def merge_params
      params.merge!(JSON.parse(request.body.read))
    end

    def table
      @tables_repository.find(params[:name].capitalize)
    end

    def player
      @players_repository.find(params[:token])
    end
  end
end
