require 'spec_helper'

RSpec.describe PokerArena::Cash do
  describe '#rebuy_max' do
    it 'decrease amount and increase stake' do
      cash = described_class.new
      cash.rebuy_max

      expect(cash.stack).to eql(100)
      expect(cash.bankroll).to eql(9_900)
    end
  end

  describe '#broke?' do
    it 'return false when bankroll > 0' do
      cash = described_class.new

      expect(cash.broke?).to eql(false)
    end

    it 'return true when bankroll == 0' do
      cash  = described_class.new

      100.times do
        cash.rebuy_max
        cash.stack_to_stakes(cash.stack)
        cash.delete_stakes
      end

      expect(cash.broke?).to eql(true)
    end
  end
end
