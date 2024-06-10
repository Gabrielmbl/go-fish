# TODO: Get game to start TDD
# TODO: Talk about scenarios for play_round

require_relative 'player'
require_relative 'deck'

class Game
  attr_reader :players

  def initialize(players)
    @players = players
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
end
