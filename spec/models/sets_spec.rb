require 'spec_helper'

RSpec.describe PokerArena::Set do
  let(:players) {
    [
      PokerArena::Player.new(pseudo: 'Jon'),
      PokerArena::Player.new(pseudo: 'Tyrion')
    ]
  }
  let(:set) { described_class.new(players: players) }

  describe '#add_game' do
    it 'change from 0 set to 1' do
      expect {
        set.add_game(PokerArena::Game.new(status: :blinds))
      }.to change {
        set.games.count
      }.from(0).to(1)
    end

    it 'raise TypeError with wrong type of argument' do
      expect { set.add_game('Hack') }.to raise_error(TypeError)
    end
  end
end
