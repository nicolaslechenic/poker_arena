# frozen_string_literal: true

module PokerArena
  module Application
    module UseCases
      class InitializeTables
        def initialize(tables_repository)
          @tables_repository = tables_repository
        end

        def call
          while @tables_repository.all.count < @tables_repository.names.count
            table = Domain::Entities::Table.new(tables_repository: @tables_repository)
            @tables_repository.persist(table)
          end
        end
      end
    end
  end
end
