# frozen_string_literal: true

module PokerArena
  class GamesController < Sinatra::Base
    def initialize(app, options)
      super(app)
      @tables_repository = options.fetch(:tables_repository)
      @players_repository = options.fetch(:players_repository)
      @start_game_use_case = UseCases::StartGame.new(@tables_repository)
      @process_action_use_case = UseCases::ProcessAction.new(@tables_repository, @players_repository)
      @get_game_state_use_case = UseCases::GetGameState.new(@tables_repository, @players_repository)
      @get_table_state_use_case = UseCases::GetTableState.new(@tables_repository)
    end

    post '/api/tables/:name/start' do
      merge_params
      result = @start_game_use_case.call(params[:name], params[:token])
      json(result)
    end

    post '/api/tables/:name/action' do
      merge_params
      result = @process_action_use_case.call(
        params[:name],
        params[:token],
        params[:action_type],
        params[:value]
      )
      json(result)
    end

    get '/api/tables/:name/state' do
      result = @get_game_state_use_case.call(params[:name], params[:token])
      json(result)
    end

    get '/api/tables/:name/spectate' do
      result = @get_table_state_use_case.call(params[:name])
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
