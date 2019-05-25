require 'spec_helper'

RSpec.describe PokerArena::Table do
  describe '#seat_in' do
    it 'add players to the table' do
      hero = PokerArena::Player.new
      vilain = PokerArena::Player.new
      table = described_class.new
      table.seat_in(hero)
      table.seat_in(vilain)

      expect(table.players.count).to eql(2)
    end

    it 'restrict the number of players per table' do
      player_1 = PokerArena::Player.new
      player_2 = PokerArena::Player.new
      player_3 = PokerArena::Player.new

      table = described_class.new
      table.seat_in(player_1)
      table.seat_in(player_2)

      expect { table.seat_in(player_3) }.to raise_error(RangeError)
    end

    it 'restrict to uniq player' do
      table = described_class.new

      expect { table.seat_in('John Snow') }.to raise_error(TypeError)
    end

    it 'restrict to uniq player' do
      player = PokerArena::Player.new
      table = described_class.new
      table.seat_in(player)

      expect { table.seat_in(player) }.to raise_error(IndexError)
    end
  end
end
