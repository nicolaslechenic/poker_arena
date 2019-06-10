module PokerArena
  class TablesController < Sinatra::Base
    def initialize(app, options)
      super(app)
      @tables_repository = options.fetch(:tables_repository)
    end

    get '/api/tables/generate' do
      table = Table.new(tables_repository: @tables_repository)
      @tables_repository.persist(table)

      json(table: table.name)
    end

    get '/api/tables' do
      informations = @tables_repository.all.map do |table|
        {
          name: table.name,
          max_players: table.max_players,
          available_seats: table.available_seats
        }
      end

      json(tables: informations)
    end
  end
end
