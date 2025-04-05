# frozen_string_literal: true

module PokerArena
  module Interfaces
    module Controllers
      class GamesController < Sinatra::Base
        def initialize(app, options)
          super(app)
          @tables_repository = options.fetch(:tables_repository)
          @players_repository = options.fetch(:players_repository)
          @hand_histories_repository = options.fetch(:hand_histories_repository)
          @start_game_use_case = Application::UseCases::StartGame.new(@tables_repository)
          @process_action_use_case = options.fetch(:process_action_use_case,
                                                   Application::UseCases::ProcessAction.new(@tables_repository,
                                                                                            @players_repository))
          @get_game_state_use_case = Application::UseCases::GetGameState.new(@tables_repository, @players_repository)
          @get_table_state_use_case = Application::UseCases::GetTableState.new(@tables_repository)
          @get_hand_history_use_case = Application::UseCases::GetHandHistory.new(@hand_histories_repository)
          @save_hand_history_use_case = Application::UseCases::SaveHandHistory.new(@hand_histories_repository,
                                                                                   @tables_repository)
        end

        post %r{/api/tables/([^/]+)/start/?} do |name|
          params[:name] = name
          merge_params
          result = @start_game_use_case.call(params[:name], params[:token])
          json(result)
        end

        post %r{/api/tables/([^/]+)/action/?} do |name|
          params[:name] = name
          merge_params
          result = @process_action_use_case.call(
            params[:name],
            params[:token],
            params[:action_type],
            params[:value]
          )
          json(result)
        end

        get %r{/api/tables/([^/]+)/state/?} do |name|
          params[:name] = name
          result = @get_game_state_use_case.call(params[:name], params[:token])
          json(result)
        end

        get %r{/api/tables/([^/]+)/spectate/?} do |name|
          params[:name] = name
          result = @get_table_state_use_case.call(params[:name])
          json(result)
        end

        # Hand history endpoints
        get %r{/api/hand_histories/([^/]+)/?} do |id|
          result = @get_hand_history_use_case.call(id)
          json(result)
        end

        get %r{/api/tables/([^/]+)/hand_histories/?} do |name|
          result = @get_hand_history_use_case.get_table_histories(name)
          json(result)
        end

        post %r{/api/tables/([^/]+)/save_hand_history/?} do |name|
          result = @save_hand_history_use_case.call(name)
          json(result)
        end

        private

        def merge_params
          params.merge!(JSON.parse(request.body.read))
        rescue StandardError
          {}
        end
      end
    end
  end
end
