require 'spec_helper'

describe Rook do
  let(:board) { Board.new(empty=true) }

  describe 'valid_move?' do
    let(:rook)    { Rook.new({ row: 0, column: 0, color: :white }) }
    before(:each) { board.place(0, 0, rook) }

    it 'accepts lateral move on empty board' do
      expect(rook.valid_move?(7, 0, board)).to be true
    end

    it 'accepts vertical move on empty board' do
      expect(rook.valid_move?(0, 7, board)).to be true
    end

    it 'rejects diagonal move' do
      expect(rook.valid_move?(3, 3, board)).to be false
    end

    it 'accepts vertical & lateral move on board with no other pieces in the way' do
      board.place(5, 0, Rook.new({row: 5, column: 0 }))
      board.place(0, 5, Rook.new({row: 0, column: 5 }))

      expect(rook.valid_move?(4, 0, board)).to be true
      expect(rook.valid_move?(0, 4, board)).to be true
    end

    it 'rejects vertical & lateral move on board with other pieces in the way' do
      board.place(0, 5, Rook.new({row: 0, column: 5 }))
      board.place(5, 0, Rook.new({row: 5, column: 0 }))

      expect(rook.valid_move?(0, 6, board)).to be false
      expect(rook.valid_move?(6, 0, board)).to be false
    end

    it 'rejects move to square containing same colored piece' do
      board.place(0, 5, Rook.new({row: 0, column: 5, color: :white }))

      expect(rook.valid_move?(0, 5, board)).to be false
    end

    it 'accepts move to square containing different colored piece' do
      board.place(0, 5, Rook.new({row: 0, column: 5, color: :black }))

      expect(rook.valid_move?(0, 5, board)).to be true
    end
  end
end