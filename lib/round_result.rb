class RoundResult
  attr_accessor :game, :current_player, :opponent, :rank_asked, :card_received, :card_fished, :books_added

  def initialize(current_player:, opponent:, game: nil, rank_asked: nil, card_received: nil, card_fished: nil,
                 books_added: nil)
    @game = game
    @current_player = current_player
    @opponent = opponent
    @rank_asked = rank_asked
    @card_received = card_received
    @card_fished = card_fished
    @books_added = books_added
  end

  def display_for(player)
    if player == current_player
      player_messages
    else
      opponents_messages
    end
  end

  def opponents_messages
    return "#{current_player} asked #{opponent} for #{rank_asked} and got them." if card_received

    if rank_asked == card_fished
      "#{current_player} fished for the card that they asked #{opponent} for and got #{card_fished}. #{current_player}'s turn again."
    else
      "#{current_player} asked #{opponent} for #{rank_asked} and went fishing."
    end
  end

  def player_messages
    message =
      if books_added
        message_with_books
      else
        message_no_books
      end
  end

  def message_no_books
    return "You asked #{opponent} for #{rank_asked} and went fishing and got #{card_fished}." unless card_received

    "You asked #{opponent} for #{rank_asked} and got #{card_received}."
  end

  def message_with_books
    unless card_received
      return "You asked #{opponent} for #{rank_asked} and went fishing and got #{card_fished}.\nYou added book(s) of #{books_added.join(', ')}."
    end

    "You asked #{opponent} for #{rank_asked} and got #{card_received}.\nYou added book(s) of #{books_added.join(', ')}."
  end
end
