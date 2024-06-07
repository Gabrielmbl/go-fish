class Card
  attr_reader :suit, :rank, :numerical_rank

  RANKS = %w[2 3 4 5 6 7 8 9 10 J Q K A].freeze
  SUITS = %w[C D H S].freeze

  def initialize(rank, suit)
    @rank = rank
    @suit = suit
    @numerical_rank = RANKS.index(rank)
  end

  def ==(other)
    rank == other.rank
  end
end
