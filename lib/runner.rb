player1 = WarPlayer.new('Player 1')
player2 = WarPlayer.new('Player 2')
game = WarGame.new(player1, player2)
game.start
until game.winner
  # input = what card do you want, self.player?
  # until is true that self.player actually has the card they want
  #   Game will check if self.player has those cards
  # input2 = self.player, who do you want to ask for that card?

  # play_round(get 2, from jullian)
  #   Does jullian have it? If Yes -> move 2 from jullian to gabriel
  #                         If No -> Player draws from the pond
  #   current_player gets updated to next one

end
