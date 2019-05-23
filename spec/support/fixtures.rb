module Fixtures
  def self.cards
    @cards ||= YAML.load_file('./spec/fixtures/cards.yml')
  end
end
