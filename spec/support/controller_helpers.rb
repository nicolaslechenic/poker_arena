# frozen_string_literal: true

module ControllerHelpers
  def self.included(base)
    base.class_eval do
      let(:controller_class) do
        Class.new(PokerArena::GamesController) do
          configure do
            disable :protection
            set :environment, :test
            set :show_exceptions, false
            set :raise_errors, true
          end

          def table
            @tables_repository.find(params[:name].capitalize) ||
              raise(StandardError, "Table not found: #{params[:name]}")
          end

          def player
            @players_repository.find(params[:token]) ||
              raise(StandardError, "Player not found: #{params[:token]}")
          end
        end
      end

      def app
        controller_class.new(
          ->(_env) { [404, { 'Content-Type' => 'text/plain' }, ['Not Found']] },
          tables_repository: tables_repository,
          players_repository: players_repository
        )
      end
    end
  end
end

RSpec.configure do |config|
  config.include ControllerHelpers, type: :controller
end
