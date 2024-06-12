require_relative '../lib/round_result'

RSpec.describe RoundResult do
  describe '#display_for' do
    before do
      # GIVEN
      # @result = RoundResult.new(current_player: 'P1', opponent: 'P2', rank_asked: '2', card_received: '2')
      # binding.irb
    end
    it 'should return player gets rank from opponent to player' do
      @result = RoundResult.new(current_player: 'P1', opponent: 'P2', rank_asked: '2', card_received: '2')

      # WHEN
      result_message = @result.display_for(@result.current_player)
      # THEN
      expect(result_message).to eq "You asked #{@result.opponent} for #{@result.rank_asked} and got #{@result.card_received}."
    end
    it 'should return opponent gets rank from player to opponents' do
      @result = RoundResult.new(current_player: 'P1', opponent: 'P2', rank_asked: '2', card_received: '2')

      # WHEN
      result_message = @result.display_for(@result.opponent)
      # THEN
      expect(result_message).to eq "#{@result.current_player} asked #{@result.opponent} for #{@result.rank_asked} and got them."
    end

    before do
      # GIVEN
      @result = RoundResult.new(current_player: 'P1', opponent: 'P2', rank_asked: '2', card_fished: '2')
    end
    fit 'should return the card that the player fished to player' do
      # WHEN
      result_message = @result.display_for(@result.current_player)
      # THEN
      expect(result_message).to eq "You asked #{@result.opponent} for #{@result.rank_asked} and went fishing and got #{@result.card_fished}."
    end

    it 'should return the card that the player fished to opponent if rank_asked is equal to card_fished' do
      # GIVEN
      @result = RoundResult.new(current_player: 'P1', opponent: 'P2', rank_asked: '2', card_fished: '2')

      # WHEN
      result_message = @result.display_for(@result.opponent)
      # THEN
      expect(result_message).to eq "#{@result.current_player} fished for the card that they asked #{@result.opponent} for and got #{@result.card_fished}. #{@result.current_player}'s turn again."
    end

    it 'should not return the card that the player fished to opponent if rank_asked is not equal to card_fished' do
      @result.card_fished = '3'
      # WHEN
      result_message = @result.display_for(@result.opponent)
      # THEN
      expect(result_message).to eq "#{@result.current_player} asked #{@result.opponent} for #{@result.rank_asked} and went fishing."
    end

    before do
      # GIVEN
      @result = RoundResult.new(current_player: 'P1', opponent: 'P2', rank_asked: '2', card_fished: '2',
                                books_added: ['2'])
    end

    it 'should return the card that the player fished and added books to player' do
      # WHEN
      result_message = @result.display_for(@result.current_player)
      # THEN
      expect(result_message).to eq "You asked #{@result.opponent} for #{@result.rank_asked} and went fishing and got #{@result.card_fished}.\nYou added book(s) of #{@result.books_added.join(', ')}."
    end

    it 'should return the card that the player fished and added books to opponent' do
      # WHEN
      result_message = @result.display_for(@result.opponent)
      # THEN
      expect(result_message).to eq "You asked #{@result.opponent} for #{@result.rank_asked} and went fishing and got #{@result.card_fished}."
    end
  end
end
