require 'spec_helper'

RSpec.describe PokerArena::BoardSerializer do
  it 'return expected json format' do
    board = PokerArena::Board.new

    PokerArena::Card.array('As 7h 3d').each do |card|
      board.receive_card(card)
    end

    expect(described_class.new(board: board).()).to eql(
      {
        flop: %w[As 7h 3d],
        turn: nil,
        river: nil
      }
    )
  end
end
