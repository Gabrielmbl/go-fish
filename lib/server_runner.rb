require_relative '../lib/server'

server = Server.new
server.start
while true
  begin
    client = server.accept_new_client
    next unless client

    server.record_player_names(client)
    game = server.create_game_if_possible
    server.run_game(game) if game
  rescue StandardError
    server.stop
  end
end
