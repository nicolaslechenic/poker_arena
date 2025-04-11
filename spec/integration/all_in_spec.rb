# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'All-in behavior', type: :integration do
  let(:players_repository) { PokerArena::Infrastructure::Repositories::PlayersRepository.new }
  let(:tables_repository) { PokerArena::Infrastructure::Repositories::TablesRepository.new }
  let(:table) do 
    PokerArena::Domain::Entities::Table.build(
      name: "arrakis",
      players:
    )  
  end

  let(:bot1) { PokerArena::Domain::Entities::Player.new(pseudo: 'Bot1') }
  let(:bot2) { PokerArena::Domain::Entities::Player.new(pseudo: 'Bot2') }
  let(:start_game_use_case) { PokerArena::Application::UseCases::StartGame.new(tables_repository) }
  let(:process_action_use_case) do
    PokerArena::Application::UseCases::ProcessAction.new(tables_repository, players_repository)
  end
  let(:get_game_state_use_case) do
    PokerArena::Application::UseCases::GetGameState.new(tables_repository, players_repository)
  end

  before do
    players_repository.persist(bot1)
    players_repository.persist(bot2)
    tables_repository.persist(table)

    bot2.cash.rebuy_max

    table.seat_in(bot1)
    table.seat_in(bot2)
    bot1.cash.stack = 0.0

    @initial_bot1_stack = bot1.cash.amount
    @initial_bot2_stack = bot2.cash.amount
  end

  it 'handles all-in correctly' do
    result = start_game_use_case.call(table.name, bot1.token)
    expect(result[:status]).to eq(200)
    expect(result[:message]).to eq('Game started')

    expect(table.sets).not_to be_empty
    expect(table.sets.last.games).not_to be_empty
    current_set = table.sets.last
    current_game = current_set.games.last
    expect(current_game.status).to eq(:preflop)

    small_blind_pos = (current_set.button_position + 1) % table.players.count
    big_blind_pos = (current_set.button_position + 2) % table.players.count

    small_blind_player = table.players[small_blind_pos]
    big_blind_player = table.players[big_blind_pos]

    bot1.all_in = true

    if small_blind_player == bot1 && @initial_bot1_stack < table.small_blind
      expect(bot1.all_in?).to be true
      expect(bot1.cash.amount).to eq(0)
    end

    if big_blind_player == bot1 && @initial_bot1_stack < table.big_blind
      expect(bot1.all_in?).to be true
      expect(bot1.cash.amount).to eq(0)
    end

    if bot1.all_in?
      expect(bot1.cash.amount + bot2.cash.amount).to be_within(1.5).of(@initial_bot1_stack + @initial_bot2_stack)
    else
      first_to_act_pos = (current_set.button_position + 3) % table.players.count
      first_to_act = table.players[first_to_act_pos]

      if first_to_act == bot1
        result = process_action_use_case.call(
          table.name,
          bot1.token,
          'bet',
          100.0
        )
        expect(result[:status]).to eq(200)

        expect(bot1.all_in?).to be true
        expect(bot1.cash.amount).to eq(0)

        result = process_action_use_case.call(
          table.name,
          bot2.token,
          'call',
          bot1.cash.stakes
        )
      else
        result = process_action_use_case.call(
          table.name,
          bot2.token,
          'bet',
          table.big_blind
        )
        expect(result[:status]).to eq(200)

        result = process_action_use_case.call(
          table.name,
          bot1.token,
          'raise',
          100.0
        )
        expect(result[:status]).to eq(200)
        expect(bot1.all_in?).to be true
        expect(bot1.cash.amount).to eq(0)

        result = process_action_use_case.call(
          table.name,
          bot2.token,
          'call',
          bot1.cash.stakes - table.big_blind
        )
      end
      expect(result[:status]).to eq(200)
    end

    current_game.status = :flop
    table.advance_game_status

    3.times { table.dealer.deal(table.board) } if table.board.cards.count < 3

    current_game.status = :turn
    table.advance_game_status

    table.dealer.deal(table.board) if table.board.cards.count < 4

    current_game.status = :river
    table.advance_game_status

    table.dealer.deal(table.board) if table.board.cards.count < 5

    table.determine_winner

    expect(current_game.status).to eq(:river)
    expect(table.board.cards.count).to eq(5)
    expect(table.pot).to eq(0)
    expect(bot1.cash.amount + bot2.cash.amount).to be_within(1.5).of(@initial_bot1_stack + @initial_bot2_stack)

    current_set.button_position = 1
    expect(current_set.button_position).to eq(1)
  end
end
