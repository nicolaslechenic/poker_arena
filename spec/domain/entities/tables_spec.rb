# frozen_string_literal: true

require 'spec_helper'

RSpec.describe PokerArena::Domain::Entities::Table do
  let(:repo) { PokerArena::Infrastructure::Repositories::TablesRepository.new }
  let(:table) { described_class.new(tables_repository: repo) }

  describe '#initialize' do
    it "selects a name that isn't already in the repository" do
      existing_table_names = repo.all.map(&:name)
      expect(existing_table_names).not_to include(table.name)
    end

    context 'when all names are taken in the repository' do
      it 'raises an error' do
        expect do
          loop do
            table = described_class.new(tables_repository: repo)
            repo.persist(table)
          end
        end.to raise_error(/No more available table names in that repository/)
      end
    end
  end

  describe '#seat_in' do
    it 'add players to the table' do
      expect do
        table.seat_in(PokerArena::Domain::Entities::Player.new(pseudo: 'Jon Snow'))
        table.seat_in(PokerArena::Domain::Entities::Player.new(pseudo: 'Jon Snow'))
      end.to change {
        table.players.count
      }.from(0).to(2)
    end

    it 'restrict the number of players per table' do
      table.seat_in(PokerArena::Domain::Entities::Player.new(pseudo: 'Jon Snow'))
      table.seat_in(PokerArena::Domain::Entities::Player.new(pseudo: 'Jon Snow'))

      expect { table.seat_in(PokerArena::Domain::Entities::Player.new(pseudo: 'Jon Snow')) }
        .to raise_error(RangeError)
    end

    it 'restrict to uniq player' do
      expect { table.seat_in('John Snow') }.to raise_error(TypeError)
    end

    it 'restrict to uniq player' do
      player = PokerArena::Domain::Entities::Player.new(pseudo: 'Jon Snow')

      table.seat_in(player)

      expect { table.seat_in(player) }.to raise_error(IndexError)
    end
  end
end
