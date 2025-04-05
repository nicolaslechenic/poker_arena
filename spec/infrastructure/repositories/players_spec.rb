# frozen_string_literal: true

require 'spec_helper'

RSpec.describe PokerArena::Infrastructure::Repositories::PlayersRepository do
  describe '#persist' do
    let(:repo) { described_class.new(token_size: 1) }
    let(:unpersisted_player) { PokerArena::Domain::Entities::Player.new(pseudo: 'Jon Snow') }

    it 'sets the token on the given player' do
      expect { repo.persist(unpersisted_player) }
        .to change { unpersisted_player.token }
        .from(nil)
        .to(be_a(String))
    end

    it 'adds the player into the repository' do
      expect { repo.persist(unpersisted_player) }
        .to change { repo.all }
        .from(an_array_excluding(unpersisted_player))
        .to(include(unpersisted_player))
    end

    context 'when the player has already been persisted' do
      let!(:already_persisted_player) do
        PokerArena::Domain::Entities::Player.new(pseudo: 'Jon Snow').tap { |player| repo.persist(player) }
      end

      it "maintains the player's token" do
        expect { repo.persist(already_persisted_player) }
          .not_to(change { already_persisted_player.token })
      end

      it 'keeps only one copy of the player in the repository' do
        expect { repo.persist(already_persisted_player) }
          .not_to(change { repo.all.size })
      end
    end
  end
end
