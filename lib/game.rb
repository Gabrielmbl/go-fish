require_relative 'player'
require_relative 'deck'

class Game
  attr_reader :players
  attr_accessor :current_player, :deck, :game_winner, :players_with_highest_number_of_books, :round_state

  STARTING_CARD_COUNT = 5

  def initialize(players)
    @players = *players
    @current_player = players.first
    @players_with_highest_number_of_books = nil
    @game_winner = nil
    @round_state = []
    # last_turn_player
    # last_turn_opponent
    # last_turn_card_taken
    # last_turn_book
  end

  def deck
    @deck ||= Deck.new
  end

  def start
    deck.shuffle
    deal_to_players
  end

  def deal_to_players
    players.each do |player|
      STARTING_CARD_COUNT.times { player.add_to_hand([deck.deal]) }
    end
  end

  def play_round(current_player, opponent, rank)
    round_state.clear
    return unless current_player_has_rank?(rank)

    if opponent.hand_has_ranks?(rank)
      move_cards_from_opponent_to_current_player(current_player, opponent, rank)
    else
      card = current_player_fish(current_player, opponent)
      update_current_player(current_player) if card.rank != rank
    end

    round_state << current_player.add_to_books
    puts "#{display_line}\n"
  end

  def move_cards_from_opponent_to_current_player(current_player, opponent, rank)
    opponent.hand.each do |card|
      next unless card.rank == rank

      current_player.add_to_hand([card])
      puts "#{opponent.name} gave #{current_player.name} the card Rank: #{card.rank}, Suit: #{card.suit}"
      round_state << "#{opponent.name} gave #{current_player.name} the card Rank: #{card.rank}, Suit: #{card.suit}\n"
    end

    opponent.remove_by_rank(rank)
  end

  def current_player_fish(current_player, opponent)
    puts "#{opponent.name} told #{current_player.name} to go fish"
    round_state << "#{opponent.name} told #{current_player.name} to go fish\n"
    card = deck.deal
    current_player.add_to_hand(card)
    puts "#{current_player.name} drew a card Rank: #{card.rank}, Suit: #{card.suit}\n#{display_line}"
    round_state << "#{current_player.name} drew a card Rank: #{card.rank}, Suit: #{card.suit}\n#{display_line}\n"
    card
  end

  def update_current_player(current_player)
    current_player_index = players.index(current_player)
    next_player_index = (current_player_index + 1) % players.length
    self.current_player = players[next_player_index]
  end

  def current_player_has_rank?(rank)
    if current_player.hand_has_ranks?(rank)
      true
    else
      puts 'Ask for a rank that you already have in your hand'
      round_state << "Ask for a rank that you already have in your hand\n#{display_line}\n"
      false
    end
  end

  def winner
    return if deck.cards.nil?

    return nil if players.any? { |player| player.hand.count > 0 }

    max_number_of_books = players.map { |player| player.books.cards_array.count }.max

    self.players_with_highest_number_of_books = players.select { |player| player.books.count == max_number_of_books }

    compare_book_values(players_with_highest_number_of_books)

    game_winner
  end

  def compare_book_values(players_with_highest_number_of_books)
    self.game_winner = players_with_highest_number_of_books.max_by { |player| player.books.value }
    losers = players.reject { |player| player == game_winner }
    puts "#{game_winner.name} wins with number of books: #{game_winner.books.count} and value of books: #{game_winner.books.value}\n"
    round_state << "#{game_winner.name} wins with number of books: #{game_winner.books.count} and value of books: #{game_winner.books.value}\n#{display_line}\n"
    losers.each do |loser|
      puts "#{loser.name} has number of books: #{loser.books.count} and value of books: #{loser.books.value}\n#{display_line}\n"
      round_state << "#{loser.name} has number of books: #{loser.books.count} and value of books: #{loser.books.value}\n#{display_line}\n"
    end
  end

  def check_empty_hand_or_draw_five(current_player = self.current_player)
    return unless current_player.hand.empty?

    winner if deck.cards.empty?

    puts "#{current_player.name} has no cards in their hand"
    round_state << "#{current_player.name} has no cards in their hand\n"

    current_player.add_to_hand([deck.deal]) until deck.cards.empty? || current_player.hand.count == STARTING_CARD_COUNT
    current_player.hand
  end

  def display_line
    '----------------------------------'
  end
end
