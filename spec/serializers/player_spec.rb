# frozen_string_literal: true

require 'spec_helper'

RSpec.describe PokerArena::PlayerSerializer do
  it 'return expected json format' do
    pseudo = 'Jon Snow'
    repo = PokerArena::PlayersRepository.new
    player = PokerArena::Player.new(pseudo: pseudo)
    repo.persist(player)

    expect(described_class.new(player: player).call).to eql(
      {
        pseudo: pseudo,
        token: player.token
      }
    )
  end

  it 'return expected json format without token' do
    pseudo = 'Jon Snow'
    repo = PokerArena::PlayersRepository.new
    player = PokerArena::Player.new(pseudo: pseudo)
    repo.persist(player)

    expect(described_class.new(player: player).call(without: [:token])).to eql({ pseudo: pseudo })
  end
end
