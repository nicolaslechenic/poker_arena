# frozen_string_literal: true

require 'spec_helper'

RSpec.describe PokerArena::Application::UseCases::InitializeTables do
  let(:tables_repository) { PokerArena::Infrastructure::Repositories::TablesRepository.new }
  let(:use_case) { described_class.new(tables_repository) }

  describe '#call' do
    it 'creates tables for all predefined names' do
      expect(tables_repository.all).to be_empty

      use_case.call
      expect(tables_repository.all.count).to eq(tables_repository.names.count)

      table_names = tables_repository.all.map(&:name)
      expect(table_names.uniq.count).to eq(table_names.count)
      expect(table_names - tables_repository.names).to be_empty
    end

    context 'when some tables already exist' do
      before do
        table = PokerArena::Domain::Entities::Table.new(tables_repository: tables_repository)
        tables_repository.persist(table)
      end

      it 'creates tables for the remaining predefined names' do
        expect(tables_repository.all.count).to eq(1)

        use_case.call

        expect(tables_repository.all.count).to eq(tables_repository.names.count)

        table_names = tables_repository.all.map(&:name)
        expect(table_names.uniq.count).to eq(table_names.count)
        expect(table_names - tables_repository.names).to be_empty
      end
    end

    context 'when all tables already exist' do
      before do
        tables_repository.names.count.times do
          table = PokerArena::Domain::Entities::Table.new(tables_repository: tables_repository)
          tables_repository.persist(table)
        end
      end

      it 'does not create any new tables' do
        expect(tables_repository.all.count).to eq(tables_repository.names.count)

        use_case.call

        expect(tables_repository.all.count).to eq(tables_repository.names.count)
      end
    end
  end
end
