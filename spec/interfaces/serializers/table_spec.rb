# frozen_string_literal: true

require 'spec_helper'

RSpec.describe PokerArena::Interfaces::Serializers::TableSerializer do
  it 'return expected json format' do
    repo = PokerArena::Infrastructure::Repositories::TablesRepository.new
    table = PokerArena::Domain::Entities::Table.new(tables_repository: repo)
    repo.persist(table)

    expect(described_class.new(table: table).call).to eql(
      {
        name: table.name,
        limit: 100,
        big_blind: 1.0,
        small_blind: 0.5,
        max_players: 2,
        available_players: 2,
        pot: 0.0
      }
    )
  end
end
