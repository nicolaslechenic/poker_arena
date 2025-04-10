# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Complete poker hand between two bots', type: :integration do
  let(:players_repository) { PokerArena::Infrastructure::Repositories::PlayersRepository.new }
  let(:tables_repository) { PokerArena::Infrastructure::Repositories::TablesRepository.new }
  let(:table) { PokerArena::Domain::Entities::Table.new(tables_repository: tables_repository) }
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

    bot1.cash.rebuy_max
    bot2.cash.rebuy_max

    table.seat_in(bot1)
    table.seat_in(bot2)

    @initial_bot1_stack = bot1.cash.amount
    @initial_bot2_stack = bot2.cash.amount
  end

  it 'completes a full hand with proper turn order and stack updates' do
    result = start_game_use_case.call(table.name, bot1.token)
    expect(result[:status]).to eq(200)
    expect(result[:message]).to eq('Game started')

    expect(table.sets).not_to be_empty
    expect(table.sets.last.games).not_to be_empty
    current_set = table.sets.last
    current_game = current_set.games.last
    expect(current_game.status).to eq(:preflop)

    expect(bot1.cards.count).to eq(2)
    expect(bot2.cards.count).to eq(2)

    expect(table.pot).to eq(table.small_blind + table.big_blind)

    small_blind_pos = (current_set.button_position + 1) % table.players.count
    big_blind_pos = (current_set.button_position + 2) % table.players.count

    table.players[small_blind_pos]
    table.players[big_blind_pos]

    first_to_act_pos = (current_set.button_position + 3) % table.players.count
    first_to_act = table.players[first_to_act_pos]

    game_state = get_game_state_use_case.call(table.name, first_to_act.token)
    expect(game_state[:state]).to eq('active')
    expect(game_state[:game][:current_player][:pseudo]).to eq(first_to_act.pseudo)

    result = process_action_use_case.call(
      table.name,
      first_to_act.token,
      'call',
      table.big_blind
    )
    expect(result[:status]).to eq(200)
    expect(result[:message]).to eq('Action processed')

    expect(current_game.actions.count).to eq(3)
    expect(current_game.actions.last.type).to eq(:call)

    next_to_act = first_to_act == bot1 ? bot2 : bot1

    game_state = get_game_state_use_case.call(table.name, next_to_act.token)
    expect(game_state[:state]).to eq('active')
    expect(game_state[:game][:current_player][:pseudo]).to eq(next_to_act.pseudo)

    result = process_action_use_case.call(
      table.name,
      next_to_act.token,
      'call',
      0
    )
    expect(result[:status]).to eq(200)

    table.advance_game_status if current_game.status == :preflop

    expect(current_game.status).to eq(:flop)
    expect(table.board.cards.count).to eq(3)

    result = process_action_use_case.call(
      table.name,
      first_to_act.token,
      'bet',
      table.big_blind
    )
    expect(result[:status]).to eq(200)

    result = process_action_use_case.call(
      table.name,
      next_to_act.token,
      'call',
      table.big_blind
    )
    expect(result[:status]).to eq(200)

    table.advance_game_status if current_game.status == :flop

    expect(current_game.status).to eq(:turn)
    expect(table.board.cards.count).to eq(4)

    result = process_action_use_case.call(
      table.name,
      first_to_act.token,
      'call',
      0
    )
    expect(result[:status]).to eq(200)

    result = process_action_use_case.call(
      table.name,
      next_to_act.token,
      'bet',
      table.big_blind * 2
    )
    expect(result[:status]).to eq(200)

    result = process_action_use_case.call(
      table.name,
      first_to_act.token,
      'fold',
      0
    )
    expect(result[:status]).to eq(200)

    folding_player = first_to_act
    winning_player = next_to_act

    current_game.status = :river
    table.determine_winner
    current_set.button_position = 1

    expect(current_set.button_position).to eq(1)

    expect(table.pot).to eq(0)

    folding_player == bot1 ? @initial_bot1_stack : @initial_bot2_stack
    initial_winning_stack = winning_player == bot1 ? @initial_bot1_stack : @initial_bot2_stack

    expect(winning_player.cash.amount).to be > initial_winning_stack
    expect(winning_player.cash.amount).not_to eq(initial_winning_stack)
    expect(bot1.cash.amount + bot2.cash.amount).to be_within(1.5).of(@initial_bot1_stack + @initial_bot2_stack)
  end
end
