# frozen_string_literal: true

module PokerArena
  module Interfaces
    module Controllers
      class TablesController < Sinatra::Base
        def initialize(app, options)
          super(app)
          @tables_repository = options.fetch(:tables_repository)
          @players_repository = options.fetch(:players_repository)
        end

        # Handle both with and without trailing slash
        get %r{/api/tables/?} do
          tables =
            @tables_repository.all.map do |table|
              Serializers::TableSerializer.new(table: table).call
            end

          json(tables: tables)
        end

        get %r{/api/tables/create/?} do
          current_table = Domain::Entities::Table.new(tables_repository: @tables_repository)

          if @tables_repository.persist(current_table)
            output =
              Serializers::TableSerializer.new(table: current_table).call

            json(status: 200, table: output)
          else
            json(status: 400)
          end
        end

        get %r{/api/tables/([^/]+)/?} do |name|
          params[:name] = name
          serialized_players =
            table.players.map do |player|
              Serializers::PlayerSerializer.new(player: player).call(without: [:token])
            end

          output =
            Serializers::TableSerializer.new(table: table).call(with: { players: serialized_players })

          json(output)
        end

        post %r{/api/tables/([^/]+)/join/?} do |name|
          params[:name] = name
          merge_params
          if table.seat_in(player)
            json(status: 200)
          else
            json(status: 400)
          end
        end

        post %r{/api/tables/([^/]+)/leave/?} do |name|
          params[:name] = name
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
          @tables_repository.find(params[:name])
        end

        def player
          @players_repository.find(params[:token])
        end
      end
    end
  end
end
