require_relative 'deck'

class Player
  attr_reader :name, :hand, :books

  def initialize(name = 'Random Name', hand: [], books: [])
    @name = name
    @hand = hand
    @books = books
  end

  def add_to_hand(cards)
    hand.unshift(*cards)
  end

  def remove_by_rank(rank)
    hand.delete_if { |card| card.rank == rank }
  end

  def hand_has_ranks?(rank)
    hand.any? { |card| card.rank == rank }
  end

  def hand_has_books?
  end
end
