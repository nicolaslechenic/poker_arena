module PokerArena
  class PlayersController < Sinatra::Base
    get '/api/players/generate' do
      token = Player.generate
      json(player: token)
    end
  end
end
