require 'spec_helper'

describe Queen do
  let(:board) { Board.new(empty=true) }

  describe 'valid_move?' do
    context 'Diagonal Move' do
      let(:queen)   { Queen.new({ row: 4, column: 1, color: :white }) }
      before(:each) { board.place(4, 1, queen) }
    
      it 'allows a move to upper right diagonal' do
        expect(queen.valid_move?(7, 4, board)).to be true
      end

      it 'allows a move to lower left diagonal' do
        expect(queen.valid_move?(3, 0, board)).to be true
      end

      it 'allows a move to upper left diagonal' do
        expect(queen.valid_move?(5, 0, board)).to be true
      end

      it 'allows a move to upper left diagonal' do
        expect(queen.valid_move?(3, 2, board)).to be true
      end

      it 'rejects a move to not on diagonal' do
        expect(queen.valid_move?(3, 3, board)).to be false
      end

      it 'allows move on a diagonal with other piece not in the way' do
        board.place(7, 4, Pawn.new({row: 7, column: 4, color: :white}))
        expect(queen.valid_move?(6, 3, board)).to be true
      end

      it 'rejects move on a diagonal with other piece in the way' do
        board.place(6, 3, Pawn.new({row: 6, column: 3, color: :white}))
        expect(queen.valid_move?(7, 4, board)).to be false
        expect(queen.valid_move?(6, 3, board)).to be false
      end

      it 'accepts move on a diagonal that is a capture' do
        board.place(6, 3, Pawn.new({row: 6, column: 3, color: :black}))
        expect(queen.valid_move?(6, 3, board)).to be true
      end

      it 'accepts move on a diagonal that is a capture w/a piece in the way' do
        board.place(5, 2, Pawn.new({row: 6, column: 3, color: :black}))
        board.place(6, 3, Pawn.new({row: 6, column: 3, color: :black}))
        expect(queen.valid_move?(6, 3, board)).to be false
      end
    end

    context 'Vertical/Horizontal row' do
      let(:queen)   { Queen.new({ row: 0, column: 0, color: :white }) }
      before(:each) { board.place(0, 0, queen) }

      it 'accepts lateral move on empty board' do
        expect(queen.valid_move?(7, 0, board)).to be true
      end

      it 'accepts vertical move on empty board' do
        expect(queen.valid_move?(0, 7, board)).to be true
      end      

      it 'accepts vertical & lateral move on board with no other pieces in the way' do
        board.place(5, 0, Rook.new({row: 5, column: 0 }))
        board.place(0, 5, Rook.new({row: 0, column: 5 }))

        expect(queen.valid_move?(4, 0, board)).to be true
        expect(queen.valid_move?(0, 4, board)).to be true
      end

      it 'rejects vertical & lateral move on board with other pieces in the way' do
        board.place(0, 5, Rook.new({row: 0, column: 5 }))
        board.place(5, 0, Rook.new({row: 5, column: 0 }))

        expect(queen.valid_move?(0, 6, board)).to be false
        expect(queen.valid_move?(6, 0, board)).to be false
      end

      it 'rejects move to square containing same colored piece' do
        board.place(0, 5, Rook.new({row: 0, column: 5, color: :white }))

        expect(queen.valid_move?(0, 5, board)).to be false
      end

      it 'accepts move to square containing different colored piece' do
        board.place(0, 5, Rook.new({row: 0, column: 5, color: :black }))

        expect(queen.valid_move?(0, 5, board)).to be true
      end
    end
  end
end