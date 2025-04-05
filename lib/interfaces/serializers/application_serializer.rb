# frozen_string_literal: true

module PokerArena
  module Interfaces
    module Serializers
      class ApplicationSerializer
        def call(with: {}, without: {})
          cpy = full_json.dup
          without.each { |key| cpy.delete(key) }
          cpy.merge!(with)

          cpy
        end
      end
    end
  end
end
