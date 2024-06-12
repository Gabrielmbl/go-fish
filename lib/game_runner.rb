# lib/game_runner.rb

require_relative 'game'
require_relative 'server'

class GameRunner
  attr_accessor :game, :clients, :server, :prompted_players

  def initialize(game, *clients, server)
    @game = game
    @clients = clients
    @server = server
    @prompted_players = []
  end

  def run
    game.start

    run_loop until game.game_winner
  end

  # TODO: Fix messaging -> Create RoundResult class
  # TODO: Guard from typing the name of someone else when recording names
  # TODO: Guard from mistakenly typing your own name to ask
  # TODO: Guard from writing opponent's names wrong
  def run_loop(game_current_player = game.current_player)
    current_player_client = server.players.key(game_current_player)

    if game.check_empty_hand_or_draw_five
      server.send_message(current_player_client, game.round_state.first)
      game.round_state.clear
      return
    end

    ask_for_move(current_player_client, game_current_player)

    opponent_player, rank = receive_oponent_and_rank(current_player_client)
    return unless opponent_player && rank

    game.play_round(game_current_player, opponent_player, rank)
    send_round_outcome(current_player_client, game_current_player)
  end

  def receive_oponent_and_rank(current_player_client)
    opponent, rank = capture_input(current_player_client).split(',').map(&:strip)
    return unless opponent && rank

    opponent_player = game.players.find { |player| player.name == opponent }
    [opponent_player, rank]
  end

  def send_round_outcome(client, game_current_player)
    game.round_state.each { |state| clients.each { |client| server.send_message(client, state) } }
    display_hand(client, game_current_player)
    prompted_players.clear
  end

  def ask_for_move(client, game_current_player)
    return if prompted_players.include?(client)

    display_hand(client, game_current_player)
    display_opponent_names(client)
    prompt_move_request(client)
    prompted_players << client
  end

  def prompt_move_request(client)
    client.puts('Enter the name of the player you want to request a card from and the rank of the card you want. e.g. "Kevin, 5":')
  end

  def display_hand(client, game_current_player)
    hand = game_current_player.hand.map { |card| "#{card.rank} of #{card.suit}" }.join(', ')
    client.puts("\nYour hand:\n#{display_line}\n#{hand}\n#{display_line}")
  end

  def display_opponent_names(client)
    opponent_names = game.players.map(&:name).reject { |name| name == game.current_player.name }
    client.puts("\nOpponents:\n#{display_line}\n#{opponent_names.join(', ')}\n#{display_line}")
  end

  def display_line
    '----------------------------------'
  end

  def capture_input(client)
    client.read_nonblock(1000).chomp
  rescue IO::WaitReadable
    ''
  end
end
