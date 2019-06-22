require 'spec_helper'

RSpec.describe PokerArena::Match do
  let(:players) {
    [
      PokerArena::Player.new(pseudo: 'Jon'),
      PokerArena::Player.new(pseudo: 'Tyrion')
    ]
  }
  let(:match) { described_class.new(players: players) }

  describe '#add_set' do
    it 'change from 0 set to 1' do
      expect {
        match.add_set(PokerArena::Set.new)
      }.to change {
        match.sets.count
      }.from(0).to(1)
    end

    it 'raise TypeError with wrong type of argument' do
      expect { match.add_set('Hack') }.to raise_error(TypeError)
    end
  end
end
