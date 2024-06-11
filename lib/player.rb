require_relative 'deck'
require_relative 'book'

class Player
  attr_reader :name, :books
  attr_accessor :hand

  def initialize(name = 'Random Name', hand: [], books: Book.new)
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
    ranks = hand.map(&:rank)
    ranks.each do |rank|
      return true if ranks.count(rank) == 4
    end
    false
  end

  def add_to_books
    rank_counts = hand.map(&:rank).group_by(&:itself).transform_values(&:count)
    rank_counts.each do |rank, count|
      next unless count == 4

      cards = hand.select { |card| card.rank == rank }
      books.cards_array << cards
      remove_by_rank(rank)
      return "#{name} added a book of #{rank}s"
    end
    nil
  end
end
