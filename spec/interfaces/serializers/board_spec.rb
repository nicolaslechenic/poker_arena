# frozen_string_literal: true

require 'spec_helper'

RSpec.describe PokerArena::Interfaces::Serializers::BoardSerializer do
  it 'return expected json format' do
    board = PokerArena::Domain::Entities::Board.new

    PokerArena::Domain::Entities::Card.array('As 7h 3d').each do |card|
      board.receive_card(card)
    end

    expect(described_class.new(board: board).call).to eql(
      {
        flop: %w[As 7h 3d],
        turn: nil,
        river: nil
      }
    )
  end
end
