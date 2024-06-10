class GameRunner
end

# lib/war_socket_runner.rb

require_relative 'game'
require_relative 'server'

class WarSocketRunner
  attr_accessor :game, :clients, :server, :pending_players, :prompted_players

  def initialize(game, *clients, server)
    @game = game
    @clients = clients
    @server = server
    @pending_players = clients.dup
    @prompted_players = []
  end

  def run
    game.start
    run_loop until game.game_winner
  end

  def run_loop
    return unless ready

    game.play_round
    game.round_state.each { |state| clients.each { |client| server.provide_input(client, state) } }
    prompted_players.clear
    self.pending_players = clients.dup
  end

  def prompt_enter(client)
    client.puts('Type play to play your card:')
  end

  def ready
    # clients.each do |client|
    #   # prompt_enter(client) if pending_players.include?(client)
    #   prompt_enter(client) if pending_players.include?(client) && !prompted_players.include?(client)
    #   prompted_players << client
    # end
    clients.each do |client|
      unless prompted_players.include?(client)
        prompt_enter(client)
        prompted_players << client
      end
    end
    clients.each { |client| pending_players.delete(client) if player_ready(client) }
    # clients.each { |client| client.puts('You are ready') if player_ready(client) }
    pending_players.empty?
  end

  def player_ready(client)
    output = server.capture_output(client).chomp
    output == 'play'
  end

  def capture_input(client)
    client.read_nonblock(1000).chomp
  rescue IO::WaitReadable
    ''
  end
end
