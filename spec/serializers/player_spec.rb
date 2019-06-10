require 'spec_helper'

RSpec.describe PokerArena::PlayerSerializer do
  it 'return expected json format' do
    pseudo = 'Jon Snow'
    repo = PokerArena::PlayersRepository.new
    player = PokerArena::Player.new(pseudo: pseudo)
    repo.persist(player)

    expect(described_class.new(player: player).()).to eql(
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

    expect(described_class.new(player: player).(without: [:token])).to eql({ pseudo: pseudo })
  end
end
