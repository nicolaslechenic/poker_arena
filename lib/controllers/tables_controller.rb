module PokerArena
  class TablesController < ApplicationController
    get '/api/tables' do
      tables = Table.informations
      json(tables: tables)
    end
  end
end
