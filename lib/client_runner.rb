# lib/war_socket_client_runner.rb

require 'socket'
require_relative 'war_socket_client'

puts "Type in the server's port number:"
port_number = gets.chomp.to_i

client = WarSocketClient.new(port_number)

while true
  output = ''
  output = client.capture_output until output != ''
  if output.include?(':')
    print output
    client.provide_input(gets.chomp)
    # binding.irb
  else
    puts output
  end
end
