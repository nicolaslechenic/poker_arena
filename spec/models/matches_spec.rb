require 'spec_helper'

RSpec.describe PokerArena::Match do
  describe '#status' do
    let(:tables_repo) { PokerArena::TablesRepository.new }
    let(:table) { PokerArena::Table.new(tables_repository: tables_repo) }
    let(:match) {described_class.new(table: table) }

    it 'return waiting_for_player with one player seated' do
      match.join(PokerArena::Player.new(pseudo: 'Jon Snow'))

      expect(match.status).to eq(:waiting_for_player)
    end

    it 'return ingame with two player seated' do
      %w[Jon Tyrion].each do |pseudo|
        match.join(PokerArena::Player.new(pseudo: pseudo))
      end

      expect(match.status).to eq(:ingame)
    end
  end
end
