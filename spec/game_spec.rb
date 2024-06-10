# spec/game_spec.rb

require_relative '../lib/game'
require_relative '../lib/player'
require_relative '../lib/deck'

RSpec.describe Game do
  let(:player1) { Player.new('gabriel') }
  let(:player2) { Player.new('lucas') }
  let(:game) { Game.new([player1, player2]) }

  describe '#initialize' do
    it 'responds to players' do
      expect(game).to respond_to :players
    end
  end

  describe '#start' do
    it 'should shuffle the deck' do
      expect(game.deck).to receive(:shuffle).once
      game.start
    end

    it 'should deal 5 cards to each player' do
      game.start
      expect(player1.hand.count).to eq(5)
      expect(player2.hand.count).to eq(5)
    end
  end
end
