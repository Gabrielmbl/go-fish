# spec/server_spec.rb

require 'socket'
require_relative '../lib/server'
require 'game'
require 'client'

class MockClient
  attr_reader :socket, :output

  def initialize(port)
    @socket = TCPSocket.new('localhost', port)
  end

  def provide_input(text)
    @socket.puts(text)
  end

  def capture_output(delay = 0.1)
    sleep(delay)
    @output = @socket.read_nonblock(1000)
  rescue IO::WaitReadable
    @output = ''
  end

  def capture_input(delay = 0.1)
    sleep(delay)
    @output = @socket.read_nonblock(1000) # not gets which blocks
  rescue IO::WaitReadable
    @output = ''
  end

  def close
    @socket.close if @socket
  end
end

RSpec.describe Server do
  before(:each) do
    @clients = []
    @server = Server.new
    @server.start
    sleep 0.1 # ensure server is started
  end

  after(:each) do
    @server.stop
    @clients.each do |client|
      client.close
    end
  end

  it 'is not listening on a port before it is started' do
    @server.stop
    expect { Client.new(@server.port_number) }.to raise_error(Errno::ECONNREFUSED)
  end

  describe '#record_player_names' do
    before do
      @client1 = Client.new(@server.port_number)
      @clients.push(@client1)
      @server_client = @server.server.accept_nonblock
    end

    it 'should return player name if the server captures output' do
      expect(@server.players.count).to be 0
      @client1.provide_input("Player 1\n")
      @server.record_player_names(@server_client)
      expect(@server.players.count).to be 1
      expect(@server.players[@server_client].name).to eq 'Player 1'
    end
  end

  describe '#record_player_names' do
    it 'should return player name if the server captures output' do
      client1 = Client.new(@server.port_number)
      @clients.push(client1)
      @server_client = @server.accept_new_client
      expect(@server.players.count).to be 0
      client1.provide_input("Player 1\n")
      @server.record_player_names(@server_client)
      expect(@server.players.count).to be 1
      expect(@server.players[@server_client].name).to eq 'Player 1'
    end
  end

  describe '#create_game_if_possible' do
    before do
      @client1 = Client.new(@server.port_number)
      @clients.push(@client1)
      @server_client = @server.server.accept_nonblock
      @client1.provide_input("Player 1\n")
      @server.record_player_names(@server_client)
    end
    it 'accepts new clients and starts a game if possible' do
      @server.create_game_if_possible
      expect(@server.games.count).to be 0
      client2 = Client.new(@server.port_number)
      @clients.push(client2)
      @server_client = @server.accept_new_client
      client2.provide_input("Player 2\n")
      @server.record_player_names(@server_client)
      expect(@server.players.count).to be 2
      @server.create_game_if_possible
      expect(@server.games.count).to be 1
    end

    it "returns a game object when there's 2 players or more" do
      client2 = Client.new(@server.port_number)
      @clients.push(client2)
      @server_client = @server.accept_new_client
      client2.provide_input("Player 2\n")
      @server.record_player_names(@server_client)
      game = @server.create_game_if_possible
      expect(game).respond_to?(:play_round)
    end
  end
end
