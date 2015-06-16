describe Bishop do
  let(:board) { Board.new(empty=true) }

  describe 'move_type' do
    let(:bishop)  { Bishop.new({ row: 4, column: 1, color: :white }) }
    before(:each) { board.place(4, 1, bishop) }
  
    it 'allows a move to upper right diagonal' do
      expect(bishop.move_type(7, 4, board)[:valid]).to be true
    end

    it 'allows a move to lower left diagonal' do
      expect(bishop.move_type(3, 0, board)[:valid]).to be true
    end

    it 'allows a move to upper left diagonal' do
      expect(bishop.move_type(5, 0, board)[:valid]).to be true
    end

    it 'allows a move to upper left diagonal' do
      expect(bishop.move_type(3, 2, board)[:valid]).to be true
    end

    it 'rejects a move to not on diagonal' do
      expect(bishop.move_type(3, 3, board)[:valid]).to be false
      expect(bishop.move_type(4, 4, board)[:valid]).to be false
    end

    it 'allows move on a diagonal with other piece not in the way' do
      board.place(7, 4, Pawn.new({row: 7, column: 4, color: :white}))
      expect(bishop.move_type(6, 3, board)[:valid]).to be true
    end

    it 'rejects move on a diagonal with other piece in the way' do
      board.place(6, 3, Pawn.new({row: 6, column: 3, color: :white}))
      expect(bishop.move_type(7, 4, board)[:valid]).to be false
      expect(bishop.move_type(6, 3, board)[:valid]).to be false
    end

    it 'accepts move on a diagonal that is a capture' do
      board.place(6, 3, Pawn.new({row: 6, column: 3, color: :black}))
      expect(bishop.move_type(6, 3, board)[:valid]).to be true
    end

    it 'accepts move on a diagonal that is a capture w/a piece in the way' do
      board.place(5, 2, Pawn.new({row: 6, column: 3, color: :black}))
      board.place(6, 3, Pawn.new({row: 6, column: 3, color: :black}))
      expect(bishop.move_type(6, 3, board)[:valid]).to be false
    end
  end

  describe 'determine_check_squares' do
    it 'returns correct check squares - king on upper right' do
      bishop = Bishop.new({row: 0, column: 0, color: :white})
      king   = King.new({row: 4, column: 4, color: :black})
      board.place(0, 0, bishop)
      board.place(4, 4, king)

      check_squares = bishop.determine_check_squares(king.row, king.column, board)

      expect(check_squares.length).to eq 3
      expect(check_squares.index([1, 1])).to_not be_nil
      expect(check_squares.index([2, 2])).to_not be_nil
      expect(check_squares.index([3, 3])).to_not be_nil
    end

    it 'returns correct check squares - king on lower right' do
      bishop = Bishop.new({row: 4, column: 0, color: :white})
      king   = King.new({row: 0, column: 4, color: :black})
      board.place(4, 0, bishop)
      board.place(0, 4, king)

      check_squares = bishop.determine_check_squares(king.row, king.column, board)

      expect(check_squares.length).to eq 3
      expect(check_squares.index([3, 1])).to_not be_nil
      expect(check_squares.index([2, 2])).to_not be_nil
      expect(check_squares.index([1, 3])).to_not be_nil
    end

    it 'returns correct check squares - king on upper left' do
      bishop = Bishop.new({row: 5, column: 3, color: :white})
      king   = King.new({row: 7, column: 5, color: :black})
      board.place(5, 3, bishop)
      board.place(7, 5, king)

      check_squares = bishop.determine_check_squares(king.row, king.column, board)

      expect(check_squares.length).to eq 1
      expect(check_squares.index([6, 4])).to_not be_nil
    end

    it 'returns correct check squares - king on lower left' do
      bishop = Bishop.new({row: 5, column: 3, color: :white})
      king   = King.new({row: 2, column: 0, color: :black})
      board.place(5, 3, bishop)
      board.place(2, 0, king)

      check_squares = bishop.determine_check_squares(king.row, king.column, board)

      expect(check_squares.length).to eq 2
      expect(check_squares.index([4, 2])).to_not be_nil
      expect(check_squares.index([3, 1])).to_not be_nil
    end
  end
end
