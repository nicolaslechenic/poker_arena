module Fixtures
  def self.cards
    @cards ||= YAML.load_file('./spec/fixtures/cards.yml')
  end

  def self.straights
    @straights ||= YAML.load_file('./spec/fixtures/straights.yml')
  end
end
