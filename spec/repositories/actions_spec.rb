require 'spec_helper'

RSpec.describe PokerArena::ActionsRepository do
  describe '#persist' do
    let(:repo) { described_class.new }
    let(:unpersisted_action) { PokerArena::Action.new(pseudo: 'Jon', type: :bet, value: 12) }

    it 'adds the match into the repository' do
      expect { repo.persist(unpersisted_action) }
        .to change { repo.all }
        .from(an_array_excluding(unpersisted_action))
        .to(include(unpersisted_action))
    end

    context 'when the match has already been persisted' do
      let!(:already_persisted_action) do
        unpersisted_action.tap do |action|
          repo.persist(action)
        end
      end

      it 'keeps only one copy of the match in the repository' do
        expect { repo.persist(already_persisted_action) }
          .not_to change { repo.all.size }
      end
    end
  end
end
