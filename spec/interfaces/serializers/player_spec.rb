# frozen_string_literal: true

require 'spec_helper'

RSpec.describe PokerArena::Interfaces::Serializers::PlayerSerializer do
  it 'return expected json format' do
    pseudo = 'Jon Snow'
    repo = PokerArena::Infrastructure::Repositories::PlayersRepository.new
    player = PokerArena::Domain::Entities::Player.new(pseudo: pseudo)
    repo.persist(player)

    expect(described_class.new(player: player).call).to eql(
      {
        pseudo: pseudo,
        token: player.token,
        bankroll: player.cash.bankroll
      }
    )
  end

  it 'return expected json format without token' do
    pseudo = 'Jon Snow'
    repo = PokerArena::Infrastructure::Repositories::PlayersRepository.new
    player = PokerArena::Domain::Entities::Player.new(pseudo: pseudo)
    repo.persist(player)

    expect(described_class.new(player: player).call(without: [:token])).to eql({
                                                                                 pseudo: pseudo,
                                                                                 bankroll: player.cash.bankroll
                                                                               })
  end
end
