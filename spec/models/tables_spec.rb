require 'spec_helper'

RSpec.describe PokerArena::Table do
  let(:repo) { PokerArena::TablesRepository.new }
  let(:table) { described_class.new(tables_repository: repo) }

  describe '#initialize' do
    it "selects a name that isn't already in the repository" do
      existing_table_names = repo.all.map(&:name)
      expect(existing_table_names).not_to include(table.name)
    end

    context 'when all names are taken in the repository' do
      it 'raises an error' do
        expect {
          loop do
            table = described_class.new(tables_repository: repo)
            repo.persist(table)
          end
        }.to raise_error(/No more available table names in that repository/)
      end
    end
  end

  describe '#seat_in' do
    it 'add players to the table' do
      expect {
        table.seat_in(PokerArena::Player.new(pseudo: 'Jon Snow'))
        table.seat_in(PokerArena::Player.new(pseudo: 'Jon Snow'))
      }.to change {
        table.players.count
      }.from(0).to(2)
    end

    it 'restrict the number of players per table' do
      table.seat_in(PokerArena::Player.new(pseudo: 'Jon Snow'))
      table.seat_in(PokerArena::Player.new(pseudo: 'Jon Snow'))

      expect { table.seat_in(PokerArena::Player.new(pseudo: 'Jon Snow')) }
        .to raise_error(RangeError)
    end

    it 'restrict to uniq player' do
      expect { table.seat_in('John Snow') }.to raise_error(TypeError)
    end

    it 'restrict to uniq player' do
      player = PokerArena::Player.new(pseudo: 'Jon Snow')

      table.seat_in(player)

      expect { table.seat_in(player) }.to raise_error(IndexError)
    end

    it 'initialize match when full of players' do
      %w[Jon Tyrion].each do |pseudo|
        table.seat_in(PokerArena::Player.new(pseudo: pseudo))
      end

      expect(table.matches.count).to eql(1)
    end
  end

  describe '#seat_out' do
    it 'remove player to the table' do
      player = PokerArena::Player.new(pseudo: 'Jon Snow')
      table.seat_in(player)

      expect {
        table.seat_out(player)
      }.to change {
        table.players.count
      }.from(1).to(0)
    end
  end

  describe '#status' do
    it 'return waiting_for_player with one player seated' do
      table.seat_in(PokerArena::Player.new(pseudo: 'Jon Snow'))

      expect(table.status).to eq(:waiting_for_players)
    end

    it 'return ingame with two player seated' do
      %w[Jon Tyrion].each do |pseudo|
        table.seat_in(PokerArena::Player.new(pseudo: pseudo))
      end

      expect(table.status).to eq(:in_match)
    end
  end
end
