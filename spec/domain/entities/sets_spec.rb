# frozen_string_literal: true

require 'spec_helper'

RSpec.describe PokerArena::Domain::Entities::Set do
  let(:players) do
    [
      PokerArena::Domain::Entities::Player.new(pseudo: 'Jon'),
      PokerArena::Domain::Entities::Player.new(pseudo: 'Tyrion')
    ]
  end
  let(:set) { described_class.new(players: players) }

  describe '#add_game' do
    it 'change from 0 set to 1' do
      expect do
        set.add_game(PokerArena::Domain::Entities::Game.new(status: :blinds))
      end.to change {
        set.games.count
      }.from(0).to(1)
    end

    it 'raise TypeError with wrong type of argument' do
      expect { set.add_game('Hack') }.to raise_error(TypeError)
    end
  end
end
