# frozen_string_literal: true

require 'spec_helper'

RSpec.describe PokerArena::Domain::Entities::Deck do
  it 'return 52 cards' do
    expect(described_class.new.remaining_cards.count).to eql(52)
  end
end
