module PokerArena
  class ActionsController < Sinatra::Base
    def initialize(app, options)
      super(app)
      @actions_repository = options.fetch(:actions_repository)
      @tables_repository = options.fetch(:tables_repository)
      @players_repository = options.fetch(:players_repository)
    end

    get '/api/actions/:pseudo' do

    end

    post '/api/actions/fold' do
      params.merge!(JSON.parse(request.body.read))

      table   = @tables_repository.find(params[:name].capitalize)
      player  = @players_repository.find(params[:token])
    end

    post '/api/actions/call' do
      params.merge!(JSON.parse(request.body.read))
    end

    post '/api/actions/bet' do
      params.merge!(JSON.parse(request.body.read))
    end

    post '/api/actions/raise' do
      params.merge!(JSON.parse(request.body.read))
    end

    post '/api/actions/all-in' do
      params.merge!(JSON.parse(request.body.read))
    end
  end
end
