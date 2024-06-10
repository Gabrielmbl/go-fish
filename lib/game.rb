# TODO: Get game to start TDD
# TODO: Talk about scenarios for play_round

require_relative 'player'
require_relative 'deck'

class Game
  attr_reader :players
  attr_accessor :current_player, :deck, :game_winner, :players_with_highest_number_of_books

  def initialize(players)
    @players = players
    @current_player = players.first
    @players_with_highest_number_of_books = nil
    @game_winner = nil
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
      5.times { player.add_to_hand([deck.deal]) }
    end
  end

  def play_round(current_player, opponent, rank)
    return unless current_player_has_rank?(rank)

    if opponent.hand_has_ranks?(rank)
      move_cards_from_opponent_to_current_player(current_player, opponent, rank)
    else
      card = current_player_fish(current_player, opponent)
      update_current_player(current_player) if card.rank != rank
    end

    current_player.add_to_books
  end

  def move_cards_from_opponent_to_current_player(current_player, opponent, rank)
    opponent.hand.each do |card|
      if card.rank == rank
        current_player.add_to_hand([card])
        puts "#{opponent.name} gave #{current_player.name} the card Rank: #{card.rank}, Suit: #{card.suit}"
      end
    end
    puts "----------------------------------\n"
    opponent.remove_by_rank(rank)
  end

  def current_player_fish(current_player, opponent)
    puts "#{opponent.name} told #{current_player.name} to go fish"
    card = deck.deal
    current_player.add_to_hand(card)
    puts "#{current_player.name} drew a card Rank: #{card.rank}, Suit: #{card.suit}"
    puts "----------------------------------\n"
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
      puts 'Ask for a rank that you have on your hand'
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
    puts "#{game_winner.name} wins with number of books: #{game_winner.books.count} and value of books: #{game_winner.books.value}\n----------------------------------\n"
  end
end
