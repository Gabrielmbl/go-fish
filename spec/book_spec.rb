require_relative '../lib/book'
require_relative '../lib/card'

RSpec.describe Book do
  describe '#initialize' do
    it 'responds to cards' do
      book = Book.new
      expect(book).to respond_to(:cards_array)
    end
  end
end
