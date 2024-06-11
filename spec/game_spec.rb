# spec/game_spec.rb

require_relative '../lib/game'
require_relative '../lib/player'
require_relative '../lib/deck'

RSpec.describe Game do
  let(:player1) { Player.new('gabriel') }
  let(:player2) { Player.new('lucas') }
  let(:player3) { Player.new('someoneelse') }
  let(:game) { Game.new([player1, player2]) }
  let(:card1) { Card.new('2', 'H') }
  let(:card2) { Card.new('2', 'D') }
  let(:card3) { Card.new('2', 'S') }
  let(:card4) { Card.new('2', 'C') }
  let(:card5) { Card.new('3', 'H') }
  let(:card6) { Card.new('3', 'D') }
  let(:card7) { Card.new('3', 'S') }
  let(:card8) { Card.new('3', 'C') }
  let(:card9) { Card.new('4', 'H') }
  let(:card10) { Card.new('4', 'D') }
  let(:card11) { Card.new('4', 'S') }
  let(:card12) { Card.new('4', 'C') }
  let(:card13) { Card.new('A', 'H') }
  let(:card14) { Card.new('A', 'D') }
  let(:card15) { Card.new('A', 'S') }
  let(:card16) { Card.new('A', 'C') }

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

  describe '#check_hand_or_draw_five' do
    it 'should return nil if the player has cards in his hand' do
      player1.add_to_hand(card1)
      expect(game.check_empty_hand_or_draw_five(player1)).to be_nil
    end

    it 'should return 5 cards from the deck if the player has no cards in his hand' do
      game.deck.cards = [card1, card2, card3, card4, card5]
      game.check_empty_hand_or_draw_five(player1)
      expect(player1.hand.count).to eq(5)
    end

    it 'should add 3 cards to the player hand if the deck only has 3 cards' do
      game.deck.cards = [card1, card2, card3]
      game.check_empty_hand_or_draw_five(player1)
      expect(player1.hand.count).to eq(3)
    end

    it 'should call winner function if the deck is empty' do
      game.deck.cards = []
      expect(game).to receive(:winner).once
      game.check_empty_hand_or_draw_five(player1)
    end
  end

  describe '#play_round' do
    before do
      player1.add_to_hand([Card.new('2', 'H')])
      player1.add_to_hand([Card.new('3', 'D')])
      player1.add_to_hand([Card.new('4', 'S')])
      player2.add_to_hand([Card.new('2', 'C')])
      player2.add_to_hand([Card.new('2', 'S')])
      player2.add_to_hand([Card.new('3', 'H')])
    end

    it "should have player1's hand include 2 of C, 2 of S, not 3 of H" do
      game.play_round(player1, player2, '2')
      expect(player1.hand).to include(Card.new('2', 'C'))
      expect(player1.hand).to include(Card.new('2', 'S'))
      expect(player1.hand).not_to include(Card.new('3', 'H'))
    end

    it "should have player2's hand include 3 of H, not 2 of C, 2 of S" do
      game.play_round(player1, player2, '2')
      expect(player2.hand).to include(Card.new('3', 'H'))
      expect(player2.hand).not_to include(Card.new('2', 'C'))
      expect(player2.hand).not_to include(Card.new('2', 'S'))
    end

    it "should have player1 draw a card if player2 doesn't have the rank" do
      game.deck.shuffle
      game.play_round(player1, player2, '4')
      expect(player1.hand.count).to eq(4)
    end

    it 'should update the current player' do
      expect(game.current_player).to eq(player1)
      game.play_round(player1, player2, '4')
      expect(game.current_player).to eq(player2)
    end

    it 'should not update current player if player1 draws a card with the rank' do
      card = Card.new('4', 'H')
      deck = Deck.new
      deck.cards = [card]
      game.deck = deck
      expect(game.current_player).to eq(player1)
      game.play_round(player1, player2, '4')
      expect(game.current_player).to eq(player1)
    end

    it 'should move from hand to books if they have 4 of a kind' do
      player1.add_to_hand([Card.new('2', 'D')])
      expect(player1.hand.count).to eq(4)
      game.play_round(player1, player2, '2')
      expect(player1.hand.count).to eq(2)
      expect(player1.books.cards_array.count).to eq(1)
    end

    it 'should return nil if the current player does not have the rank that they are asking for' do
      expect(game.play_round(player1, player2, '5')).to be_nil
    end
  end

  describe '#winner' do
    it 'should return nil if deck is not nil' do
      game.start
      expect(game.winner).to be_nil
    end

    it 'should return nil if players still have cards' do
      game.deck.cards = [Card.new('2', 'H')]
      player1.add_to_hand([Card.new('3', 'H')])
      expect(game.winner).to be_nil
    end

    it 'should return the player with the most books if the deck is nil' do
      game.deck.cards = []
      player1.add_to_hand([card1, card2, card3, card4])
      player1.add_to_books
      expect(game.winner).to eq(player1)
    end

    it 'should return winner with highest book value if both players have the same number of books' do
      player1.add_to_hand([card1, card2, card3, card4])
      player2.add_to_hand([card5, card6, card7, card8])

      game.deck.cards = []
      player1.add_to_books
      player2.add_to_books
      expect(game.winner).to eq(player2)
    end

    it 'should return winner with the highest number of books' do
      player1.add_to_hand([card1, card2, card3, card4, card5, card6, card7, card8])
      player2.add_to_hand([card9, card10, card11, card12])

      game.deck.cards = []
      player1.add_to_books
      player2.add_to_books
      expect(game.winner).to eq(player1)
    end

    it 'should only acount players with tied highest number of books for comparing values of books at the end' do
      player1.add_to_hand([card1, card2, card3, card4, card5, card6, card7, card8])
      player2.add_to_hand([card5, card6, card7, card8, card9, card10, card11, card12])
      player3.add_to_hand([card13, card14, card15, card16])

      game.deck.cards = []
      player1.add_to_books
      player2.add_to_books
      player3.add_to_books
      expect(game.winner).to eq(player2)
    end
  end

  describe 'smoke test' do
    fit 'should play the whole game to completion' do
      game.start
      until game.winner
        current_player = game.current_player
        other_player = game.players.select { |player| player != current_player }.first
        game.check_empty_hand_or_draw_five(current_player)
        rank = current_player.hand.sample.rank
        puts "#{current_player.name} is asking for rank #{rank}"
        game.play_round(current_player, other_player, rank)
      end
    end
  end
end
