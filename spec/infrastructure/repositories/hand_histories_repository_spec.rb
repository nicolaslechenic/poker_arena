# frozen_string_literal: true

require 'spec_helper'

describe PokerArena::Infrastructure::Repositories::HandHistoriesRepository do
  let(:repository) { described_class.new }
  let(:table_name) { 'azuria' }
  let(:players) do
    [
      { pseudo: 'player1', position: 0, initial_stack: 100.0 },
      { pseudo: 'player2', position: 1, initial_stack: 100.0 }
    ]
  end
  let(:actions) do
    [
      { player_position: 0, player_pseudo: 'player1', type: :bet, value: 1.0, game_status: :preflop },
      { player_position: 1, player_pseudo: 'player2', type: :call, value: 1.0, game_status: :preflop }
    ]
  end
  let(:board_cards) do
    {
      flop: %w[Ah 2d 7c],
      turn: 'Ks',
      river: '10h'
    }
  end
  let(:pot) { 2.0 }
  let(:winners) { [{ player_position: 0, amount_won: 2.0 }] }

  let(:hand_history) do
    PokerArena::Domain::Entities::HandHistory.new(
      id: nil,
      table_name: table_name,
      players: players,
      actions: actions,
      board_cards: board_cards,
      pot: pot,
      winners: winners,
      timestamp: Time.now
    )
  end

  let(:hand_history2) do
    PokerArena::Domain::Entities::HandHistory.new(
      id: nil,
      table_name: 'balamb',
      players: players,
      actions: actions,
      board_cards: board_cards,
      pot: pot,
      winners: winners,
      timestamp: Time.now
    )
  end

  describe '#persist' do
    it 'assigns an ID to a new hand history' do
      persisted = repository.persist(hand_history)
      expect(persisted.id).not_to be_nil
    end

    it 'stores the hand history in the repository' do
      persisted = repository.persist(hand_history)
      found = repository.find(persisted.id)
      expect(found).to eq(persisted)
    end

    it 'increments the ID for each new hand history' do
      first = repository.persist(hand_history)
      second = repository.persist(hand_history2)
      expect(second.id.to_i).to eq(first.id.to_i + 1)
    end
  end

  describe '#find' do
    it 'returns the hand history with the given ID' do
      persisted = repository.persist(hand_history)
      found = repository.find(persisted.id)
      expect(found.table_name).to eq(table_name)
      expect(found.players).to eq(players)
      expect(found.actions).to eq(actions)
    end

    it 'raises KeyError when the hand history is not found' do
      expect { repository.find('999') }.to raise_error(KeyError)
    end
  end

  describe '#find_by_table' do
    before do
      repository.persist(hand_history)
      repository.persist(hand_history2)
      repository.persist(hand_history) # Another history for the same table
    end

    it 'returns all hand histories for the given table' do
      repository.clear
      repository.persist(hand_history)
      repository.persist(hand_history)

      histories = repository.find_by_table(table_name)
      expect(histories.size).to eq(2)
      expect(histories.all? { |h| h.table_name == table_name }).to be true
    end

    it 'returns an empty array when no histories exist for the table' do
      histories = repository.find_by_table('nonexistent')
      expect(histories).to be_empty
    end
  end

  describe '#all' do
    before do
      repository.persist(hand_history)
      repository.persist(hand_history2)
    end

    it 'returns all hand histories' do
      repository.clear
      repository.persist(hand_history)
      repository.persist(hand_history2)

      all_histories = repository.all
      expect(all_histories.size).to eq(2)
    end
  end

  describe '#delete' do
    it 'removes the hand history with the given ID' do
      persisted = repository.persist(hand_history)
      repository.delete(persisted.id)
      expect { repository.find(persisted.id) }.to raise_error(KeyError)
    end
  end

  describe '#clear' do
    before do
      repository.persist(hand_history)
      repository.persist(hand_history2)
    end

    it 'removes all hand histories' do
      repository.clear
      expect(repository.all).to be_empty
    end

    it 'resets the ID counter' do
      repository.clear
      persisted = repository.persist(hand_history)
      expect(persisted.id).to eq('1')
    end
  end
end
