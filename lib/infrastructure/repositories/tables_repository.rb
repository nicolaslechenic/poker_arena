# frozen_string_literal: true

module PokerArena
  module Infrastructure
    module Repositories
      class TablesRepository
        # Pokemon Locations and Final Fantasy (VII, VIII, IX) Locations
        NAMES =
          %w[
            pallet-town
            viridian-city
            pewter-city
            cerulean-city
            lavender-town
            celadon-city
            saffron-city
            vermilion-city
            cinnabar-island
            indigo-plateau
            midgar
            gold-saucer
            nibelheim
            junon
            cosmo-canyon
            balamb-garden
            esthar
            timber
            dollet
            fishermans-horizon
            alexandria
            lindblum
            treno
            black-mage-village
            burmecia
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
  end
end
