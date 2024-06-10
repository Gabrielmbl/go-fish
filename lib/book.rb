require_relative 'card'

class Book
  attr_accessor :cards_array

  def initialize(cards_array = [])
    @cards_array = cards_array
  end

  def value
    sum = 0
    cards_array.each do |cards|
      sum += cards.first.numerical_rank
    end
    sum
  end

  def count
    cards_array.count
  end
end
