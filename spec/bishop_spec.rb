describe Bishop do
  let(:board) { Board.new(empty=true) }

  describe 'move_type' do
    let(:bishop)  { Bishop.new({ row: 4, column: 1, color: :white }) }
    before(:each) { board.place(4, 1, bishop) }
  
    it 'allows a move to upper right diagonal' do
      expect(bishop.move_type(7, 4, board)).to be true
    end

    it 'allows a move to lower left diagonal' do
      expect(bishop.move_type(3, 0, board)).to be true
    end

    it 'allows a move to upper left diagonal' do
      expect(bishop.move_type(5, 0, board)).to be true
    end

    it 'allows a move to upper left diagonal' do
      expect(bishop.move_type(3, 2, board)).to be true
    end

    it 'rejects a move to not on diagonal' do
      expect(bishop.move_type(3, 3, board)).to be false
      expect(bishop.move_type(4, 4, board)).to be false
    end

    it 'allows move on a diagonal with other piece not in the way' do
      board.place(7, 4, Pawn.new({row: 7, column: 4, color: :white}))
      expect(bishop.move_type(6, 3, board)).to be true
    end

    it 'rejects move on a diagonal with other piece in the way' do
      board.place(6, 3, Pawn.new({row: 6, column: 3, color: :white}))
      expect(bishop.move_type(7, 4, board)).to be false
      expect(bishop.move_type(6, 3, board)).to be false
    end

    it 'accepts move on a diagonal that is a capture' do
      board.place(6, 3, Pawn.new({row: 6, column: 3, color: :black}))
      expect(bishop.move_type(6, 3, board)).to be true
    end

    it 'accepts move on a diagonal that is a capture w/a piece in the way' do
      board.place(5, 2, Pawn.new({row: 6, column: 3, color: :black}))
      board.place(6, 3, Pawn.new({row: 6, column: 3, color: :black}))
      expect(bishop.move_type(6, 3, board)).to be false
    end
  end
end
