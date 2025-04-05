# frozen_string_literal: true

require 'spec_helper'

describe 'ProcessAction with HandHistory' do
  let(:hand_histories_repository) do
    PokerArena::Infrastructure::Repositories::HandHistoriesRepository.new
  end

  let(:tables_repository) do
    PokerArena::Infrastructure::Repositories::TablesRepository.new(nil, true)
  end

  let(:players_repository) do
    PokerArena::Infrastructure::Repositories::PlayersRepository.new
  end

  let(:table_name) { 'azuria' }

  let(:player1) do
    player = PokerArena::Domain::Entities::Player.new(pseudo: 'player1')
    player.cash.stack = 100.0
    players_repository.persist(player)
    player
  end

  let(:player2) do
    player = PokerArena::Domain::Entities::Player.new(pseudo: 'player2')
    player.cash.stack = 100.0
    players_repository.persist(player)
    player
  end

  let(:process_action_use_case) do
    PokerArena::Application::UseCases::ProcessAction.new(
      tables_repository,
      players_repository,
      hand_histories_repository
    )
  end

  let(:start_game_use_case) do
    PokerArena::Application::UseCases::StartGame.new(tables_repository)
  end

  before do
    hand_histories_repository.clear
    PokerArena::Application::UseCases::InitializeTables.new(tables_repository).call

    table = tables_repository.find(table_name)
    table.seat_in(player1)
    table.seat_in(player2)

    start_game_use_case.call(table_name, player1.token)
  end

  describe 'automatic hand history saving' do
    it 'saves hand history when a game is completed' do
      hand_histories_repository.clear

      initial_count = hand_histories_repository.all.size

      process_action_use_case.call(table_name, player1.token, 'call', 0.5)
      process_action_use_case.call(table_name, player2.token, 'check', 0)

      # binding.pry

      table = tables_repository.find(table_name)
      table.advance_game_status

      process_action_use_case.call(table_name, player1.token, 'check', 0)
      process_action_use_case.call(table_name, player2.token, 'check', 0)

      table.advance_game_status

      process_action_use_case.call(table_name, player1.token, 'check', 0)
      process_action_use_case.call(table_name, player2.token, 'check', 0)

      table.advance_game_status

      # allow_any_instance_of(PokerArena::Domain::Entities::Table).to receive(:round_completed?).and_return(true)

      process_action_use_case.call(table_name, player1.token, 'check', 0)
      process_action_use_case.call(table_name, player2.token, 'check', 0)

      expect(hand_histories_repository.all.size).to eq(initial_count + 1)

      history = hand_histories_repository.all.last
      expect(history.table_name).to eq(table_name)
      expect(history.players.size).to eq(2)
      expect(history.actions.size).to eq(9)
    end

    it 'does not save hand history for incomplete games' do
      initial_count = hand_histories_repository.all.size

      process_action_use_case.call(table_name, player1.token, 'check', 0)
      process_action_use_case.call(table_name, player2.token, 'check', 0)

      expect(hand_histories_repository.all.size).to eq(initial_count)
    end
  end
end
