module PokerArena
  class TablesController < Sinatra::Base
    def initialize(app, options)
      super(app)
      @tables_repository = options.fetch(:tables_repository)
      @players_repository = options.fetch(:players_repository)
    end

    get '/api/tables/generate' do
      table = Table.new(tables_repository: @tables_repository)
      @tables_repository.persist(table)

      json(table: table.name)
    end

    get '/api/tables' do
      tables =
        @tables_repository.all.map do |table|
          TableSerializer.new(table: table).()
        end

      json(tables: tables)
    end

    get '/api/tables/:name' do
      table = @tables_repository.find(params[:name].capitalize)

      json(
        TableSerializer.new(table: table).()
      )
    end

    post '/api/tables/:name/seat-in' do
      params.merge!(JSON.parse(request.body.read))

      table = @tables_repository.find(params[:name].capitalize)
      player = @players_repository.find(params[:token])

      if table.seat_in(player)
        json(status: 200)
      else
        json(status: 400)
      end
    end
  end
end
