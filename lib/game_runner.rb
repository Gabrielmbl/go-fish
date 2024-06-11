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

  def run_loop
    current_player_client = server.players.key(game.current_player)

    if game.check_empty_hand_or_draw_five
      server.send_message(current_player_client, game.round_state.first)
      game.round_state.clear
    end

    ask_for_move(current_player_client)

    opponent, rank = capture_input(current_player_client).split(',').map(&:strip)
    return unless opponent && rank

    opponent_player = game.players.find { |player| player.name == opponent }

    game.play_round(game.current_player, opponent_player, rank)
    game.round_state.each { |state| clients.each { |client| server.send_message(client, state) } }
    # TODO: Find out why display_hand now shows the hand of the opponent
    display_hand(current_player_client)
    prompted_players.clear
  end

  def ask_for_move(current_player_client)
    return if prompted_players.include?(current_player_client)

    display_hand(current_player_client)
    display_opponent_names(current_player_client)
    prompt_move_request(current_player_client)
    prompted_players << current_player_client
  end

  def prompt_enter(client)
    client.puts('Type ready if you are ready to play')
  end

  def prompt_move_request(client)
    client.puts('Enter the name of the player you want to request a card from and the rank of the card you want. e.g. "Kevin, 5":')
  end

  def display_hand(client)
    hand = game.current_player.hand.map { |card| "#{card.rank} of #{card.suit}" }.join(', ')
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
