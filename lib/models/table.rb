# frozen_string_literal: true

module PokerArena
  class Table
    MAX_PLAYERS = 2
    LIMIT = 100

    class << self
      def available_names(tables_repository)
        tables_repository.names - tables_repository.all.map(&:name)
      end
    end

    attr_reader :name, :players, :board, :dealer, :sets
    attr_accessor :pot

    def initialize(tables_repository:, board: Board.new, dealer: Dealer.new)
      @name = self.class.available_names(tables_repository).sample
      @pot = 0.0
      @board = board
      @dealer = dealer
      @players = []
      @sets = []

      return unless @name.nil?

      raise ArgumentError, 'No more available table names in that repository'
    end

    def max_players
      MAX_PLAYERS
    end

    def available_players
      MAX_PLAYERS - players.count
    end

    def limit
      LIMIT
    end

    def big_blind
      limit / 100.0
    end

    def small_blind
      big_blind / 2
    end

    def seat_in(player)
      raise RangeError if full?
      raise TypeError unless player.is_a?(Player)
      raise IndexError if players&.first == player

      min_required = big_blind * 10
      raise StandardError, "Not enough bankroll (minimum #{min_required})" if player.cash.bankroll < min_required

      target_stack = big_blind * 100
      transfer_amount = [target_stack, player.cash.bankroll].min

      player.cash.bankroll_to_stack(transfer_amount)

      @players << player
      @sets << Set.new(players: @players) if full?
    end

    def seat_out(player)
      @players.delete(player)
    end

    def full?
      players.count >= MAX_PLAYERS
    end

    def start_game
      raise StandardError, 'Not enough players' if players.count < 2

      @sets << Set.new(players: @players) if @sets.empty? || @sets.last.games.last&.status == :river

      current_set = @sets.last
      game = Game.new(status: :blinds)
      current_set.add_game(game)

      players.each do |player|
        player.cards = []
        2.times { dealer.deal(player) }
      end

      collect_blinds(game)

      game.status = :preflop

      true
    end

    def collect_blinds(game)
      current_set = @sets.last
      button_pos = current_set.button_position
      small_blind_pos = (button_pos + 1) % players.count
      big_blind_pos = (button_pos + 2) % players.count

      sb_player = players[small_blind_pos]
      sb_action = Action.new(
        player: sb_player,
        type: :bet,
        value: small_blind
      )
      game.add_action(sb_action)
      actual_sb = sb_player.cash.stack_to_stakes(small_blind)

      if actual_sb < small_blind
        sb_player.all_in = true
        sb_action.value = actual_sb
      end

      bb_player = players[big_blind_pos]
      bb_action = Action.new(
        player: bb_player,
        type: :bet,
        value: big_blind
      )
      game.add_action(bb_action)
      actual_bb = bb_player.cash.stack_to_stakes(big_blind)

      if actual_bb < big_blind
        bb_player.all_in = true
        bb_action.value = actual_bb
      end

      @pot += actual_sb + actual_bb
    end

    def current_player
      return nil if @sets.empty?

      current_set = @sets.last
      current_game = current_set.games.last

      if current_game.status == :preflop && current_game.actions.count <= 2
        return players[(current_set.button_position + 3) % players.count]
      end

      last_action = current_game.actions.last
      return players[current_set.button_position] if last_action.nil?

      last_player_pos = players.index(last_action.player)
      next_player_pos = (last_player_pos + 1) % players.count

      while player_folded?(players[next_player_pos], current_game) || players[next_player_pos].all_in?
        next_player_pos = (next_player_pos + 1) % players.count

        next unless next_player_pos == (last_player_pos + 1) % players.count

        active_players = players.reject { |p| player_folded?(p, current_game) }
        return active_players.first if active_players.any?

        return nil
      end

      players[next_player_pos]
    end

    def player_folded?(player, game)
      game.actions.select { |a| a.player == player }.any? { |a| a.type == :fold }
    end

    def process_action(player, action_type, value = 0)
      return false if @sets.empty?
      return false if player != current_player

      current_set = @sets.last
      current_game = current_set.games.last

      if player.all_in? && !%i[check fold].include?(action_type)
        action_type = :check
        value = 0
      end

      action = Action.new(
        player: player,
        type: action_type,
        value: value
      )

      current_game.add_action(action)

      if %i[bet call raise].include?(action_type)
        actual_amount = player.cash.stack_to_stakes(value)

        if actual_amount < value
          player.all_in = true
          action.value = actual_amount
        end

        @pot += actual_amount
      end

      advance_game_status if round_completed?

      true
    end

    def round_completed?
      return false if @sets.empty?

      current_set = @sets.last
      current_game = current_set.games.last

      active_players = players.reject { |p| player_folded?(p, current_game) }

      all_in_players = active_players.select(&:all_in?)
      return true if all_in_players.count == active_players.count - 1

      return true if all_in_players.count == active_players.count

      return false if active_players.any? { |p| player_bet(p, current_game) < current_bet(current_game) }

      last_bet_pos = last_bet_position(current_game)
      return false if last_bet_pos.nil?

      current_pos = players.index(current_player)
      (last_bet_pos + 1) % players.count == current_pos
    end

    def last_bet_position(game)
      bet_actions = game.actions.select { |a| %i[bet raise].include?(a.type) }
      return nil if bet_actions.empty?

      last_bet = bet_actions.last
      players.index(last_bet.player)
    end

    def player_bet(player, game)
      game.actions.select { |a| a.player == player && %i[bet call raise].include?(a.type) }
          .map(&:value)
          .sum
    end

    def current_bet(game)
      game.actions.select { |a| %i[bet raise].include?(a.type) }
          .map(&:value)
          .max || 0
    end

    def advance_game_status
      return if @sets.empty?

      current_set = @sets.last
      current_game = current_set.games.last

      active_players = players.reject { |p| player_folded?(p, current_game) }
      all_in_players = active_players.select(&:all_in?)

      if all_in_players.count == active_players.count
        case current_game.status
        when :preflop
          current_game.status = :flop
          3.times { dealer.deal(board) }
          current_game.status = :turn
          dealer.deal(board)
          current_game.status = :river
          dealer.deal(board)
          determine_winner
          current_set.button_position = (current_set.button_position + 1) % players.count
        when :flop
          current_game.status = :turn
          dealer.deal(board)
          current_game.status = :river
          dealer.deal(board)
          determine_winner
          current_set.button_position = (current_set.button_position + 1) % players.count
        when :turn
          current_game.status = :river
          dealer.deal(board)
          determine_winner
          current_set.button_position = (current_set.button_position + 1) % players.count
        when :river
          determine_winner
          current_set.button_position = (current_set.button_position + 1) % players.count
        end
      elsif all_in_players.count == active_players.count - 1
        case current_game.status
        when :preflop
          current_game.status = :flop
          3.times { dealer.deal(board) }
        when :flop
          current_game.status = :turn
          dealer.deal(board)
        when :turn
          current_game.status = :river
          dealer.deal(board)
        when :river
          determine_winner
          current_set.button_position = (current_set.button_position + 1) % players.count
        end
      else
        case current_game.status
        when :preflop
          current_game.status = :flop
          3.times { dealer.deal(board) }
        when :flop
          current_game.status = :turn
          dealer.deal(board)
        when :turn
          current_game.status = :river
          dealer.deal(board)
        when :river
          determine_winner
          current_set.button_position = (current_set.button_position + 1) % players.count
        end
      end
    end

    def determine_winner
      current_game = @sets.last.games.last
      active_players = players.reject { |p| player_folded?(p, current_game) }

      if active_players.count == 1
        winner = active_players.first
      else
        best_hand = nil
        winner = nil

        active_players.each do |player|
          all_cards = player.cards + board.cards

          hand = Hand.new(cards: all_cards)

          if best_hand.nil? || hand > best_hand
            best_hand = hand
            winner = player
          end
        end
      end

      winner.cash.amount += @pot
      @pot = 0
    end
  end
end
