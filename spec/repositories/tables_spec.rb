require 'spec_helper'

RSpec.describe PokerArena::TablesRepository do
  describe '#persist' do
    let(:repo) { described_class.new }
    let(:unpersisted_table) { PokerArena::Table.new(tables_repository: repo) }

    it 'adds the table into the repository' do
      expect { repo.persist(unpersisted_table) }
        .to change { repo.all }
        .from(an_array_excluding(unpersisted_table))
        .to(include(unpersisted_table))
    end

    context 'when the table has already been persisted' do
      let!(:already_persisted_table) do
        PokerArena::Table.new(tables_repository: repo).tap do |table|
          repo.persist(table)
        end
      end

      it 'keeps only one copy of the table in the repository' do
        expect { repo.persist(already_persisted_table) }
          .not_to change { repo.all.size }
      end
    end
  end
end
