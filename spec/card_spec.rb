# spec/card_spec.rb

require_relative '../lib/card'

RSpec.describe Card do
  describe '#initialize' do
    before do
      @card = Card.new('2', 'H')
    end

    it 'responds to suit, rank, and numerical rank' do
      expect(@card).to respond_to(:suit)
      expect(@card).to respond_to(:rank)
      expect(@card).to respond_to(:numerical_rank)
    end
  end

  describe '#numerical_rank' do
    it 'should return the numerical value of the rank' do
      card = Card.new('3', 'H')
      expect(card.numerical_rank).to eq(1)
    end
  end

  describe '#==' do
    before do
      @card1 = Card.new('2', 'H')
      @card2 = Card.new('2', 'C')
      @card3 = Card.new('3', 'H')
    end

    it 'returns true if the cards have the same rank' do
      expect(@card1 == @card2).to be true
    end

    it 'returns false if the cards have different ranks' do
      expect(@card1 == @card3).to be false
    end
  end
end
