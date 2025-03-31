# frozen_string_literal: true

module PokerArena
  module UseCases
    class StartGame
      def initialize(tables_repository)
        @tables_repository = tables_repository
        @presenter = Presenters::GamePresenter.new
      end

      def call(table_name, _player_token)
        table = @tables_repository.find(table_name.capitalize)

        return @presenter.error('Not enough players to start a game') if table.players.count < 2

        if table.sets.empty? || table.sets.last.games.last&.status == :river
          table.sets << Set.new(players: table.players)
        end

        current_set = table.sets.last
        game = Game.new(status: :blinds)
        current_set.add_game(game)

        deal_cards_to_players(table)
        collect_blinds(table, game)
        game.status = :preflop

        @presenter.game_start_success
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
        action = Action.new(player: player, type: type, value: value)
        game.add_action(action)
      end
    end
  end
end
