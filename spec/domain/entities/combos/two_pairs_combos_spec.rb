# frozen_string_literal: true

require 'spec_helper'

RSpec.describe PokerArena::Domain::Entities::TwoPairsCombo do
  describe '#score' do
    it 'return expected array for 7h Qc As Ac 9c' do
      cards = PokerArena::Domain::Entities::Card.array('7h Qc As Ac 9c')
      combo = described_class.new(cards: cards)

      expect(combo.score).to eql([2, 13_110_806])
    end
  end
end
