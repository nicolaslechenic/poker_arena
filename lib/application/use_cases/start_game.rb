# frozen_string_literal: true

module PokerArena
  module Application
    module UseCases
      class StartGame
        def initialize(tables_repository, players_repository = nil)
          @tables_repository = tables_repository
          @players_repository = players_repository
          @presenter = Interfaces::Presenters::GamePresenter.new
        end

        def call(table_name, _player_token)
          table = @tables_repository.find(table_name)

          begin
            table.start_game
            # Persist the table to save the updated pot
            @tables_repository.persist(table)

            # Persist the players to save their updated stacks and stakes
            if @players_repository
              table.players.each do |player|
                @players_repository.persist(player)
              end
            end

            @presenter.game_start_success
          rescue StandardError => e
            @presenter.error(e.message)
          end
        end

        private

        def deal_cards_to_players(table)
          table.players.each do |player|
            player.cards = []
            2.times { table.dealer.deal(player) }
          end
        end

        def collect_blinds(table, game)
          collect_small_blind(table, game)
          collect_big_blind(table, game)
          table.pot += table.small_blind + table.big_blind
        end

        def collect_small_blind(table, game)
          button_pos = table.sets.last.button_position
          small_blind_pos = (button_pos + 1) % table.players.count
          sb_player = table.players[small_blind_pos]
          add_blind_action(game, sb_player, :bet, table.small_blind)
        end

        def collect_big_blind(table, game)
          button_pos = table.sets.last.button_position
          big_blind_pos = (button_pos + 2) % table.players.count
          bb_player = table.players[big_blind_pos]
          add_blind_action(game, bb_player, :bet, table.big_blind)
        end

        def add_blind_action(game, player, type, value)
          action = Domain::Entities::Action.new(player: player, type: type, value: value)
          game.add_action(action)
        end
      end
    end
  end
end
