module PokerArena
  class TablesController < ApplicationController
    get '/api/tables' do
      message = { test: 'Hello' }
      json(tables: message)
    end
  end
end
