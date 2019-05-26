%w[
  card combo dealer deck
  hand player score table
].each do |file|
  require_relative "poker_arena/#{file}"
end

module PokerArena
  def self.run
    'Welcome !'
  end
end
