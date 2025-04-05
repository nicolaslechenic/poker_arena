# frozen_string_literal: true

require 'spec_helper'

RSpec.describe PokerArena::Domain::Entities::HighCardCombo do
  describe '#score' do
    it 'return expected array for Ac 8d 4c 3c 2c' do
      cards = PokerArena::Domain::Entities::Card.array('Ac 8d 4c 3c 2c')
      combo = described_class.new(cards: cards)

      expect(combo.score).to eql([0, 1_307_030_201])
    end
  end
end
