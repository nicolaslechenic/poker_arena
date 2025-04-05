# frozen_string_literal: true

require 'spec_helper'

RSpec.describe PokerArena::Domain::Entities::ThreeOfAKindCombo do
  describe '#score' do
    it 'return expected array for Ad Qc As Ac 9c' do
      cards = PokerArena::Domain::Entities::Card.array('Ad Qc As Ac 9c')
      combo = described_class.new(cards: cards)

      expect(combo.score).to eql([3, 13])
    end
  end
end
