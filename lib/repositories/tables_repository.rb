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
        if find(table.name) != table
          raise ArgumentError, "Another table named '#{table.name}' exists."
        else
          return true
        end
      end

      @tables[table.name] = table

      true
    end
  end
end
