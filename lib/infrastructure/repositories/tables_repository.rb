# frozen_string_literal: true

require 'json'
require 'fileutils'

module PokerArena
  module Infrastructure
    module Repositories
      class TablesRepository
        NAMES =
          %w[
            arrakis
            azuria
            balamb
            gnomeregan
            hyrule
            midgar
            tatooine
            terminus
            winterfell
          ].freeze

        DATA_DIR = File.join(Dir.pwd, 'data')

        def initialize(file_path = nil, test_mode = false)
          @file_path = file_path || File.join(DATA_DIR, 'tables.json')
          @serializer = Persistence::TableSerializer.new
          @store = Persistence::JsonStore.new(@file_path)
          @tables = {}

          return if test_mode

          # Initialize tables from NAMES if they don't exist
          NAMES.each do |name|
            next if @store.find(name)

            table = Domain::Entities::Table.new(tables_repository: self)
            # Force the name to be the one we want
            table.instance_variable_set('@name', name)
            persist(table)
          end

          # Load tables from store
          @store.all.each do |data|
            table = @serializer.deserialize(data, self)
            @tables[table.name] = table
          end
        end

        def all
          @tables.values
        end

        def find(name)
          @tables.fetch(name)
        end

        def names
          NAMES
        end

        def persist(table)
          if @tables.key?(table.name)
            raise ArgumentError, "Another table named '#{table.name}' exists." if find(table.name) != table

            @tables[table.name] = table
            serialized_data = @serializer.serialize(table)
            @store.save(table.name, serialized_data)
            return true
          end

          @tables[table.name] = table
          serialized_data = @serializer.serialize(table)
          @store.save(table.name, serialized_data)

          true
        end
      end
    end
  end
end
