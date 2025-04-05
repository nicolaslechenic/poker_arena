# frozen_string_literal: true

require 'spec_helper'

describe PokerArena::Application::UseCases::SaveHandHistory do
  let(:hand_histories_repository) { PokerArena::Infrastructure::Repositories::HandHistoriesRepository.new }
  let(:tables_repository) do
    PokerArena::Infrastructure::Repositories::TablesRepository.new(nil, true)
  end
  let(:table_name) { 'test_table_for_save_hand_history' }

  let(:player1) do
    player = PokerArena::Domain::Entities::Player.new(pseudo: 'player1')
    player.cash.stack = 100.0
    player
  end

  let(:player2) do
    player = PokerArena::Domain::Entities::Player.new(pseudo: 'player2')
    player.cash.stack = 100.0
    player
  end

  let(:action1) do
    PokerArena::Domain::Entities::Action.new(
      player: player1,
      type: :bet,
      value: 1.0
    )
  end

  let(:action2) do
    PokerArena::Domain::Entities::Action.new(
      player: player2,
      type: :call,
      value: 1.0
    )
  end

  let(:table) do
    table = tables_repository.find(table_name)
    table.players << player1
    table.players << player2

    set = PokerArena::Domain::Entities::Set.new(players: table.players)
    game = PokerArena::Domain::Entities::Game.new(status: :river)

    # Add actions for each game stage to simulate a complete game
    # Blinds
    blinds_action1 = PokerArena::Domain::Entities::Action.new(
      player: player1,
      type: :bet,
      value: 0.5,
      game_status: :blinds
    )
    blinds_action2 = PokerArena::Domain::Entities::Action.new(
      player: player2,
      type: :bet,
      value: 1.0,
      game_status: :blinds
    )

    # Preflop
    preflop_action1 = PokerArena::Domain::Entities::Action.new(
      player: player1,
      type: :call,
      value: 0.5,
      game_status: :preflop
    )
    preflop_action2 = PokerArena::Domain::Entities::Action.new(
      player: player2,
      type: :check,
      value: 0,
      game_status: :preflop
    )

    # Flop
    flop_action1 = PokerArena::Domain::Entities::Action.new(
      player: player1,
      type: :check,
      value: 0,
      game_status: :flop
    )
    flop_action2 = PokerArena::Domain::Entities::Action.new(
      player: player2,
      type: :check,
      value: 0,
      game_status: :flop
    )

    # Turn
    turn_action1 = PokerArena::Domain::Entities::Action.new(
      player: player1,
      type: :check,
      value: 0,
      game_status: :turn
    )
    turn_action2 = PokerArena::Domain::Entities::Action.new(
      player: player2,
      type: :check,
      value: 0,
      game_status: :turn
    )

    # River
    river_action1 = PokerArena::Domain::Entities::Action.new(
      player: player1,
      type: :check,
      value: 0,
      game_status: :river
    )
    river_action2 = PokerArena::Domain::Entities::Action.new(
      player: player2,
      type: :check,
      value: 0,
      game_status: :river
    )

    # Add all actions to the game
    game.add_action(blinds_action1)
    game.add_action(blinds_action2)
    game.add_action(preflop_action1)
    game.add_action(preflop_action2)
    game.add_action(flop_action1)
    game.add_action(flop_action2)
    game.add_action(turn_action1)
    game.add_action(turn_action2)
    game.add_action(river_action1)
    game.add_action(river_action2)

    set.add_game(game)
    table.sets << set

    table.pot = 2.0

    # Add cards to the board
    table.board.receive_card(PokerArena::Domain::Entities::Card.new('Ah'))
    table.board.receive_card(PokerArena::Domain::Entities::Card.new('2d'))
    table.board.receive_card(PokerArena::Domain::Entities::Card.new('7c'))
    table.board.receive_card(PokerArena::Domain::Entities::Card.new('Ks'))
    table.board.receive_card(PokerArena::Domain::Entities::Card.new('Td'))

    # Add cards to players
    player1.receive_card(PokerArena::Domain::Entities::Card.new('As'))
    player1.receive_card(PokerArena::Domain::Entities::Card.new('Kd'))
    player2.receive_card(PokerArena::Domain::Entities::Card.new('Qh'))
    player2.receive_card(PokerArena::Domain::Entities::Card.new('Jc'))

    table
  end

  subject { described_class.new(hand_histories_repository, tables_repository) }

  before do
    hand_histories_repository.clear
    PokerArena::Application::UseCases::InitializeTables.new(tables_repository).call
  end

  describe '#call' do
    context 'when the game is completed (river stage)' do
      it 'saves the hand history and returns success status' do
        # Call with skip_checks = true to bypass validation
        result = subject.call(table_name, true)

        expect(result[:status]).to eq(200)
        expect(result[:message]).to include('saved successfully')
        expect(result[:hand_history_id]).not_to be_nil

        history =
          hand_histories_repository.find(result[:hand_history_id])

        expect(history.table_name).to eq(table_name)
        expect(history.pot).to eq(2.0)
      end
    end

    context 'when there is no active game' do
      it 'returns an error status' do
        tables_repository.find('balamb')

        result = subject.call('balamb')

        expect(result[:status]).to eq(400)
        expect(result[:error]).to include('No active game found')
      end
    end

    context 'when the game is not completed' do
      it 'returns an error status' do
        incomplete_table = tables_repository.find('hyrule')
        incomplete_table.players << player1
        incomplete_table.players << player2

        set = PokerArena::Domain::Entities::Set.new(players: incomplete_table.players)
        game = PokerArena::Domain::Entities::Game.new(status: :flop) # Not river

        set.add_game(game)
        incomplete_table.sets << set

        result = subject.call('hyrule')

        expect(result[:status]).to eq(400)
        expect(result[:error]).to include('Game is not completed')
      end
    end
  end
end
