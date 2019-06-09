module PokerArena
  class TablesController < Sinatra::Base
    get '/api/tables/generate' do
      name = Table.generate
      json(table: name)
    end

    get '/api/tables' do
      tables = Table.informations
      json(tables: tables)
    end
  end
end
