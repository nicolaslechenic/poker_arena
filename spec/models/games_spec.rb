require 'spec_helper'

RSpec.describe PokerArena::Game do
  let(:player) { PokerArena::Player.new(pseudo: 'Jon') }
  let(:game) { described_class.new(status: :flop) }

  describe '#add_action' do
    it 'change from 0 action to 1' do
      expect {
        game.add_action(PokerArena::Action.new(player: player, type: :bet, value: 5))
      }.to change {
        game.actions.count
      }.from(0).to(1)
    end

    it 'raise TypeError with wrong type of argument' do
      expect { game.add_action('Hack') }.to raise_error(TypeError)
    end
  end
end
