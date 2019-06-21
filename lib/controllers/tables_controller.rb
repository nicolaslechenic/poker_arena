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
        table.players.map do |player|
          PlayerSerializer.new(player: player).(without: [:token])
        end

      output =
        TableSerializer.new(table: table).(with: { players: serialized_players })

      json(output)
    end
  end
end
