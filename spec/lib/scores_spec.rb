require 'spec_helper'

RSpec.describe PokerArena::Score do
  describe '#sorted' do
    it 'return 30_302_070_000 for type 3 and kicker 030207' do
      cards = PokerArena::Card.array('Ad Tc 7h 6c 5s')
      expect(described_class.sorted(cards)).to eql('1309060504')
    end
  end

  it 'raise an error for invalid type' do
    expect { described_class.new(type: 1, kicker: '123') }.to raise_error(ArgumentError)
  end

  it 'raise an error for invalid kicker' do
    expect { described_class.new(type: '1', kicker: 123) }.to raise_error(ArgumentError)
  end

  describe '.call' do
    it 'return 30_302_070_000 for type 3 and kicker 030207' do
      score = described_class.new(type: '3', kicker: '030207')
      expect(score.call).to eql(30_302_070_000)
    end
  end
end
