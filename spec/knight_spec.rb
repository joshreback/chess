describe Knight do
  let(:board) { Board.new(empty=true) }

  describe 'move_type' do
    let(:knight)  { Knight.new({ row: 4, column: 2, color: :white }) }
    before(:each) { board.place(4, 2, knight) }

    context 'legal moves' do
      it 'accepts two up and to the right' do
        expect(knight.move_type(6, 3, board)).to be true
      end

      it 'accepts two up and to the left' do
        expect(knight.move_type(6, 1, board)).to be true
      end

      it 'accepts two down and to the right' do
        expect(knight.move_type(2, 3, board)).to be true
      end

      it 'accepts two down and to the left' do
        expect(knight.move_type(2, 1, board)).to be true
      end

      it 'accepts two right and up' do
        expect(knight.move_type(5, 4, board)).to be true
      end

      it 'accepts two right and down' do
        expect(knight.move_type(3, 4, board)).to be true
      end

      it 'accepts two left and up' do
        expect(knight.move_type(5, 4, board)).to be true
      end

      it 'accepts two left and down' do
        expect(knight.move_type(5, 0, board)).to be true
      end
    end

    context 'other pieces on the square' do
      it 'accepts legal move onto square occupied by other piece' do
        board.place(5, 0, Pawn.new({ row: 5, column: 0, color: :black }))

        expect(knight.move_type(5, 0, board)).to be true
      end

      it 'rejects legal move onto square occupied by same piece' do
        board.place(5, 0, Pawn.new({ row: 5, column: 0, color: :white }))

        expect(knight.move_type(5, 0, board)).to be false
      end

      it 'accepts legal move that skips over other pieces' do
        board.place(5, 1, Pawn.new({ row: 5, column: 0, color: :white }))

        expect(knight.move_type(5, 0, board)).to be true
      end
    end
  end
end