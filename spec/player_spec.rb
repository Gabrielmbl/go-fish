# spec/player_spec.rb

require_relative '../lib/player'
require_relative '../lib/deck'
require_relative '../lib/card'

RSpec.describe Player do
  let(:player) { Player.new('gabriel') }
  let(:deck) { Deck.new }
  let(:card1) { Card.new('2', 'H') }
  let(:card2) { Card.new('3', 'H') }
  let(:card3) { Card.new('2', 'C') }
  let(:card4) { Card.new('2', 'S') }
  let(:card5) { Card.new('2', 'D') }

  describe '#initialize' do
    it 'responds to name, hand, and books' do
      expect(player).to respond_to(:name)
      expect(player).to respond_to(:hand)
      expect(player).to respond_to(:books)
    end
  end

  describe '#add_to_hand' do
    it 'should add a card to the player hand' do
      expect(player.hand).to be_empty
      player.add_to_hand(card1)
      expect(player.hand).to include(card1)
    end

    it 'should add a card to the beginning of the hand array' do
      player.add_to_hand(card1)
      player.add_to_hand(card2)
      expect(player.hand.first).to eq(card2)
    end

    it 'should add multiple cards to the hand' do
      player.add_to_hand([card1, card2])
      expect(player.hand).to include(card1, card2)
    end
  end

  describe '#remove_by_rank' do
    before do
      player.add_to_hand([card1, card2, card3])
    end
    it 'should remove cards that match the rank' do
      player.remove_by_rank(card1.rank)
      expect(player.hand).not_to include(card1, card3)
    end
  end

  describe '#hand_has_ranks?' do
    before do
      player.add_to_hand([card1, card2, card3])
    end
    it 'should return true if the player has a card with the rank' do
      expect(player.hand_has_ranks?(card1.rank)).to be true
    end

    it 'should return false if the player does not have a card with the rank' do
      expect(player.hand_has_ranks?('4')).to be false
    end
  end

  describe '#hand_has_books?' do
    before do
      card4 = Card.new('2', 'D')
      card5 = Card.new('2', 'S')
      player.add_to_hand([card1, card3, card4, card5])
    end
    it 'should return true if the player has four of a kind' do
      expect(player.hand_has_books?).to be true
    end
  end

  describe '#add_to_books' do
    before do
      player.add_to_hand([card1, card3, card4, card5])
    end
    it 'should add the cards to the player books and remove them from hand' do
      expect(player.books.cards_array).to be_empty
      player.add_to_books
      expect(player.books.cards_array).to include([card1, card3, card4, card5])
      expect(player.hand).not_to include(card1, card3, card4, card5)
    end
  end
end
