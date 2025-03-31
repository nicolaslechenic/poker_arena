# frozen_string_literal: true

module PokerArena
  class TablesRepository
    NAMES =
      %w[
        Tatooine
        Harrenhal
        Winterfell
        Eyrie
        Dragonstone
        Coruscant
        Dagobah
        Kamino
      ].freeze

    def initialize
      @tables = {}
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

        return true

      end

      @tables[table.name] = table

      true
    end
  end
end
