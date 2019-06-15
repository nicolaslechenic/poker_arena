require 'spec_helper'

RSpec.describe PokerArena::MatchesRepository do
  describe '#persist' do
    let(:tables_repo) { PokerArena::TablesRepository.new }
    let(:table) { PokerArena::Table.new(tables_repository: tables_repo) }
    let(:repo) { PokerArena::MatchesRepository.new }
    let(:unpersisted_match) { PokerArena::Match.new(table: table) }

    it 'adds the match into the repository' do
      expect { repo.persist(unpersisted_match) }
        .to change { repo.all }
        .from(an_array_excluding(unpersisted_match))
        .to(include(unpersisted_match))
    end

    context 'when the match has already been persisted' do
      let!(:already_persisted_match) do
        PokerArena::Match.new(table: table).tap do |match|
          repo.persist(match)
        end
      end

      it 'keeps only one copy of the match in the repository' do
        expect { repo.persist(already_persisted_match) }
          .not_to change { repo.all.size }
      end
    end
  end
end
