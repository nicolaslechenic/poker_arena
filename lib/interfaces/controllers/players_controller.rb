# frozen_string_literal: true

module PokerArena
  module Interfaces
    module Controllers
      class PlayersController < Sinatra::Base
        def initialize(app, options)
          super(app)
          @players_repository = options.fetch(:players_repository)
        end

        get %r{/api/players/?} do
          players =
            @players_repository.all.map do |player|
              Serializers::PlayerSerializer.new(player: player).call(without: [:token])
            end

          json(players: players)
        end

        post %r{/api/players/?} do
          params.merge!(JSON.parse(request.body.read))

          player = Domain::Entities::Player.new(pseudo: params[:pseudo])
          @players_repository.persist(player)

          if @players_repository.persist(player)
            json(status: 200, token: player.token)
          else
            json(status: 400)
          end
        end
      end
    end
  end
end
