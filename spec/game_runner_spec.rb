# spec/game_runner_spec.rb

require 'socket'
require_relative '../lib/game_runner'
require_relative 'server_spec'
require 'game'

RSpec.describe GameRunner do
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

  let(:client1) { Client.new(@server.port_number) }
  let(:client2) { Client.new(@server.port_number) }

  before do
    @client1 = Client.new(@server.port_number)
    @clients.push(@client1)
    @server_client1 = @server.accept_new_client
    @client1.provide_input("Player1\n")
    @server.record_player_names(@server_client1)
    @client2 = Client.new(@server.port_number)
    @clients.push(@client2)
    @server_client2 = @server.accept_new_client
    @client2.provide_input("Player2\n")
    @server.record_player_names(@server_client2)
    @game = @server.create_game_if_possible
    @game_runner = @server.runner(@game)
  end

  describe '#run_loop' do
    it "should make players draw cards if they don't have any cards in their hand" do
      current_player = @game.current_player
      current_player.hand = []
      expect { @game_runner.run_loop }.to change { current_player.hand.count }.by(5)
    end

    it 'should tell client to ask for a rank that they already have in their hand' do
      current_player = @game.current_player
      current_player.hand = [Card.new('2', 'H')]
      @client1.provide_input('Player2, 3')
      @game_runner.run_loop
      expect(@client1.capture_output).to include('Ask for a rank that you already have in your hand')
    end

    it 'should state the outcome of the round' do
      current_player = @game.current_player
      other_player = @game.players[1]
      current_player.hand = [Card.new('2', 'H')]
      other_player.hand = [Card.new('2', 'S')]
      @client1.provide_input('Player2, 2')
      @game_runner.run_loop
      output_expected([@client1, @client2],
                      "#{other_player.name} gave #{current_player.name} the card Rank: 2, Suit: S")
    end

    it 'displays the hand to the player that just played at the end of a round' do
      current_player = @game.current_player
      current_player.hand = [Card.new('2', 'H')]
      other_player = @game.players[1]
      other_player.hand = [Card.new('2', 'S'), Card.new('4', 'H')]
      @client1.provide_input('Player2, 2')
      @game_runner.run_loop
      output_expected([@client1], '2 of H')
      expect(@client1.capture_output).not_to include('4 of H')
      expect(@client2.capture_output).not_to include('2 of S')
    end

    it 'should prevent players from typing their own name' do
    end
  end

  def output_expected(clients, expected_output)
    clients.each { |client| expect(client.capture_output).to include expected_output }
  end

  def output_match(clients, output_to_match)
    clients.each { |client| expect(client.capture_output).to match(output_to_match) }
  end

  def clients_type_play(*clients)
    clients.each { |client| client.provide_input('ready') }
  end
end
