# lib/server.rb
require 'socket'
require_relative 'player'
require_relative 'game'
require_relative 'game_runner'

class Server
  attr_accessor :players, :games, :available_clients, :server

  def initialize
    @players = {}
    @games = []
    @available_clients = {}
  end

  def port_number
    3336
  end

  def start
    @server = TCPServer.new(port_number)
  end

  def send_message(client, message)
    client.puts(message)
  end

  def capture_output(client, delay = 0.1)
    sleep(delay)
    @output = client.read_nonblock(1000) # not gets which blocks
  rescue IO::WaitReadable
    @output = ''
  end

  def accept_new_client(player_name = 'Random Player')
    @server.accept_nonblock
  rescue IO::WaitReadable, Errno::EINTR
    puts 'No client to accept'
  end

  def record_player_names(client)
    return if players[client]

    client.puts('Enter your name:')

    player_name = client.gets.chomp

    # return unless player_name.length > 0
    player = Player.new(player_name)
    players[client] = player
    available_clients[client] = player
  end

  def create_game_if_possible
    if players.count >= 2
      puts 'there are at least 2 players'
      game = Game.new([*available_clients.values])
      available_clients.clear
      games << game
      game
    elsif players.count == 1
      # available_clients.keys.first.puts('You are waiting for a game')
    end
  end

  def run_game(game)
    runner(game).run
  end

  def runner(game)
    clients = game.players.map { |player| players.key(player) }
    game_runner = GameRunner.new(game, *clients, self)
  end

  def stop
    @server.close if @server
  end
end
