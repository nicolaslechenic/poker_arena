require 'spec_helper'

RSpec.describe PokerArena::Table do
  describe '#seat_in' do
    it 'add players to the table' do
      hero = PokerArena::Player.new(pseudo: 'Hero')
      vilain = PokerArena::Player.new(pseudo: 'Vilain')
      table = described_class.new(name: 'Winterfell')
      table.seat_in(hero)
      table.seat_in(vilain)

      expect(table.seats.count).to eql(2)
    end

    it 'restrict the number of players per table' do
      hero = PokerArena::Player.new(pseudo: 'Hero')
      vilain = PokerArena::Player.new(pseudo: 'Vilain')
      hacker = PokerArena::Player.new(pseudo: 'Hacker')

      table = described_class.new(name: 'Winterfell')
      table.seat_in(hero)
      table.seat_in(vilain)

      expect { table.seat_in(hacker) }.to raise_error(RangeError)
    end

    it 'restrict to uniq player' do
      table = described_class.new(name: 'Winterfell')

      expect { table.seat_in('John Snow') }.to raise_error(TypeError)
    end

    it 'restrict to uniq player' do
      player = PokerArena::Player.new(pseudo: 'Hero')
      table = described_class.new(name: 'Winterfell')
      table.seat_in(player)

      expect { table.seat_in(player) }.to raise_error(IndexError)
    end
  end
end
