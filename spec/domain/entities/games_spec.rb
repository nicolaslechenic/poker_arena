# frozen_string_literal: true

require 'spec_helper'

RSpec.describe PokerArena::Domain::Entities::Game do
  let(:player) { PokerArena::Domain::Entities::Player.new(pseudo: 'Jon') }
  let(:game) { described_class.new(status: :flop) }

  describe '#add_action' do
    it 'change from 0 action to 1' do
      expect do
        game.add_action(PokerArena::Domain::Entities::Action.new(player: player, type: :bet, value: 5))
      end.to change {
        game.actions.count
      }.from(0).to(1)
    end

    it 'raise TypeError with wrong type of argument' do
      expect { game.add_action('Hack') }.to raise_error(TypeError)
    end
  end
end
