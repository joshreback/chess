require 'spec_helper'

describe Rook do
  let(:board) { Board.new(empty=true) }

  describe 'move_type' do
    let(:rook)    { Rook.new({ row: 0, column: 0, color: :white }) }
    before(:each) { board.place(0, 0, rook) }

    it 'accepts lateral move on empty board' do
      expect(rook.move_type(7, 0, board)[:valid]).to be true
    end

    it 'accepts vertical move on empty board' do
      expect(rook.move_type(0, 7, board)[:valid]).to be true
    end

    it 'rejects diagonal move' do
      expect(rook.move_type(3, 3, board)[:valid]).to be false
    end

    it 'accepts vertical & lateral move on board with no other pieces in the way' do
      board.place(5, 0, Rook.new({row: 5, column: 0 }))
      board.place(0, 5, Rook.new({row: 0, column: 5 }))

      expect(rook.move_type(4, 0, board)[:valid]).to be true
      expect(rook.move_type(0, 4, board)[:valid]).to be true
    end

    it 'rejects vertical & lateral move on board with other pieces in the way' do
      board.place(0, 5, Rook.new({row: 0, column: 5 }))
      board.place(5, 0, Rook.new({row: 5, column: 0 }))

      expect(rook.move_type(0, 6, board)[:valid]).to be false
      expect(rook.move_type(6, 0, board)[:valid]).to be false
    end

    it 'rejects move to square containing same colored piece' do
      board.place(0, 5, Rook.new({row: 0, column: 5, color: :white }))

      expect(rook.move_type(0, 5, board)[:valid]).to be false
    end

    it 'accepts move to square containing different colored piece' do
      board.place(0, 5, Rook.new({row: 0, column: 5, color: :black }))

      expect(rook.move_type(0, 5, board)[:valid]).to be true
    end
  end

  describe 'determine_check_squares' do
    context 'rows' do
      it 'returns the correct intermediate squares for rows - 1' do
        rook = Rook.new({ row: 0, column: 0, color: :white })
        king = King.new({ row: 4, column: 0, color: :black })
        board.place(0, 0, rook)
        board.place(4, 0, king)

        check_squares = rook.determine_check_squares(king.row, king.column, board)
        expect(check_squares).to eq ([[1, 0], [2, 0], [3, 0]])
      end

      it 'returns the correct intermediate squares for rows - 2' do
        rook = Rook.new({ row: 4, column: 0, color: :white })
        king = King.new({ row: 0, column: 0, color: :black })
        board.place(4, 0, rook)
        board.place(0, 0, king)

        check_squares = rook.determine_check_squares(king.row, king.column, board)
        expect(check_squares).to eq ([[1, 0], [2, 0], [3, 0]])
      end
    end

    context 'columns' do
      it 'returns the correct intermediate squares for columns - 1' do
        rook = Rook.new({ row: 0, column: 0, color: :white })
        king = King.new({ row: 0, column: 4, color: :black })
        board.place(0, 0, rook)
        board.place(0, 4, king)

        check_squares = rook.determine_check_squares(king.row, king.column, board)
        expect(check_squares).to eq ([[0, 1], [0, 2], [0, 3]])
      end

      it 'returns the correct intermediate squares for rows - 2' do
        rook = Rook.new({ row: 0, column: 4, color: :white })
        king = King.new({ row: 0, column: 0, color: :black })
        board.place(0, 4, rook)
        board.place(0, 0, king)

        check_squares = rook.determine_check_squares(king.row, king.column, board)
        expect(check_squares).to eq ([[0, 1], [0, 2], [0, 3]])
      end
    end  
  end
end