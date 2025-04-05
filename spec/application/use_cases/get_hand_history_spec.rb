# frozen_string_literal: true

require 'spec_helper'

describe PokerArena::Application::UseCases::GetHandHistory do
  let(:hand_histories_repository) do
    PokerArena::Infrastructure::Repositories::HandHistoriesRepository.new
  end

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

  let(:winners) do
    [
      {
        player_position: 0,
        amount_won: 2.0
      }
    ]
  end

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
      table_name: table_name,
      players: players,
      actions: actions,
      board_cards: board_cards,
      pot: pot,
      winners: winners,
      timestamp: Time.now
    )
  end

  subject { described_class.new(hand_histories_repository) }

  before do
    hand_histories_repository.clear
  end

  describe '#call' do
    it 'returns a hand history by ID with status 200' do
      persisted =
        hand_histories_repository.persist(hand_history)

      result = subject.call(persisted.id)

      expect(result[:status]).to eq(200)
      expect(result[:hand_history][:id]).to eq(persisted.id)
      expect(result[:hand_history][:table_name]).to eq(table_name)
    end

    it 'returns a 404 error when the hand history is not found' do
      result = subject.call('bad-id')

      expect(result[:status]).to eq(404)
      expect(result[:error]).to include('not found')
    end
  end

  describe '#get_table_histories' do
    before do
      @history1 = hand_histories_repository.persist(hand_history)
      @history2 = hand_histories_repository.persist(hand_history2)
    end

    it 'returns all hand histories for a table with status 200' do
      result = subject.get_table_histories(table_name)

      expect(result[:status]).to eq(200)
      expect(result[:hand_histories].size).to eq(2)
      expect(result[:hand_histories][0][:id]).to eq(@history1.id)
      expect(result[:hand_histories][1][:id]).to eq(@history2.id)
    end

    it 'returns an empty array when no histories exist for the table' do
      result = subject.get_table_histories('bad-table-name')

      expect(result[:status]).to eq(200)
      expect(result[:hand_histories]).to be_empty
    end
  end
end
