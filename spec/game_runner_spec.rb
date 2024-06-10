# spec/game_runner_spec.rb

require 'socket'
require_relative '../lib/game_runner'
require_relative 'server_spec'
require 'game'

describe GameRunner do
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

  let(:client1) { MockClient.new(@server.port_number) }
  let(:client2) { MockClient.new(@server.port_number) }

  before do
    client1 = Client.new(@server.port_number)
    @clients.push(client1)
    @server_client1 = @server.accept_new_client('Player 1')
    client1.provide_input("Player 1\n")
    @server.record_player_names(@server_client)
    client2 = Client.new(@server.port_number)
    @clients.push(client2)
    @server_client2 = @server.accept_new_client('Player 2')
    @server_client = @server.accept_new_client
    client2.provide_input("Player 2\n")
    @server.record_player_names(@server_client)
    @game = @server.create_game_if_possible
    @game_runner = @server.runner(@game)
  end

  describe '#prompt_enter' do
    it 'should promp clients to play their card' do
      @game_runner.prompt_enter(@server_client1)
      result = client1.capture_output
      expect(result).to eq "Type play to play your card\n"
    end
  end

  describe '#player_ready' do
    xit 'should return true if it captures an ENTER from the client' do
      client1.provide_input("\n")
      client2.provide_input("\n")
      expect(@game_runner.player_ready(client1)).to be true
    end
  end

  describe '#ready' do
    xit 'should return nil if all players are ready' do
      expect(@game_runner.ready).to be_nil
    end
  end

  describe '#run' do
    xit 'should prompt clients to press ENTER to say that they are ready for the round' do
      expect(client1.capture_output.chomp).to eq 'Press ENTER to start round'
      expect(client2.capture_output.chomp).to eq 'Press ENTER to start round'
    end

    xit 'should expect a round to have been played' do
      # client1.provide input
      # client2.provide input
      # expect a round to have been played
      half_of_deck = (game.deck.num_cards / 2).floor
      client1.provide_input("\n")
      client2.provide_input("\n")
      expect(@game.player1.cards_left).not_to be half_of_deck
    end
  end

  describe '#run_loop' do
    it 'should run round and prompt clients' do
      clients = @game_runner.clients
      expect(clients).to match_array([@server_client1, @server_client2])
      @game.start
      @game_runner.run_loop
      output_expected([client1, client2], "Type play to play your card\n")
      clients_type_play(client1, client2)
      @game_runner.run_loop
      output_match([client1, client2], /Player \d wins the round/)
      @game_runner.run_loop
      output_expected([client1, client2], "Type play to play your card\n")
    end
  end

  def output_expected(clients, expected_output)
    clients.each { |client| expect(client.capture_output).to eq expected_output }
  end

  def output_match(clients, output_to_match)
    clients.each { |client| expect(client.capture_output).to match(output_to_match) }
  end

  def clients_type_play(*clients)
    clients.each { |client| client.provide_input('play') }
  end
end
