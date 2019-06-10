module PokerArena
  class ApplicationSerializer
    def call(with: {}, without: {})
      cpy = full_json.dup
      without.each { |key| cpy.delete(key) }
      cpy.merge!(with)

      cpy
    end
  end
end
