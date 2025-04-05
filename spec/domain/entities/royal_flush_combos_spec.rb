# frozen_string_literal: true

require 'spec_helper'

RSpec.describe PokerArena::Domain::Entities::RoyalFlushCombo do
  describe '#score' do
    it 'return expected array for Ac Kc Qc Jc Tc' do
      cards = PokerArena::Domain::Entities::Card.array('Ac Kc Qc Jc Tc')
      combo = described_class.new(cards: cards)

      expect(combo.score).to eql([9, 0])
    end
  end
end
