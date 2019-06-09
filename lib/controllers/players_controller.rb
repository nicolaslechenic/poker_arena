module PokerArena
  class PlayersController < ApplicationController
    get '/api/players/generate' do
      token = Player.generate
      json(player: token)
    end
  end
end
