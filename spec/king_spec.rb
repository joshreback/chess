require 'pry'

describe King do
  let(:board) { Board.new(empty=true) }

  describe 'move_type' do
    context 'basic move functionality' do
      let(:king)    { King.new({ row: 4, column: 1, color: :white })}
      before(:each) { board.place(4, 1, king) }

      it 'accepts one forward onto empty square' do
        expect(king.move_type(5, 1, board)[:valid]).to be true
      end

      it 'accepts one backward onto empty square' do
        expect(king.move_type(3, 1, board)[:valid]).to be true
      end

      it 'accepts one to right onto empty square' do
        expect(king.move_type(4, 2, board)[:valid]).to be true
      end

      it 'accepts one to left onto empty square' do
        expect(king.move_type(4, 0, board)[:valid]).to be true
      end

      it 'accepts one to upper right onto empty square' do
        expect(king.move_type(5, 2, board)[:valid]).to be true
      end

      it 'accepts one to upper left onto empty square' do
        expect(king.move_type(5, 0, board)[:valid]).to be true
      end

      it 'accepts one to lower right onto empty square' do
        expect(king.move_type(3, 2, board)[:valid]).to be true
      end

      it 'accepts one to lower left onto empty square' do
        expect(king.move_type(3, 0, board)[:valid]).to be true
      end
    end
  end

  context 'castle' do
    context 'white piece' do
      let(:king)    { King.new({ row: 0, column: 4, color: :white })}
      
      it 'accepts a castle to the right' do
        board.place(0, 4, king)
        board.place(0, 7, Rook.new({ row: 0, column: 7, color: :white }))
        
        expect(king.castle?(0, 6, board)).to be true
        expect(board.at(0, 5)).to eq Rook.new ({ row: 0, column: 5, color: :white})
      end

      it 'accepts a castle to the left' do
        board.place(0, 4, king)
        board.place(0, 0, Rook.new({ row: 0, column: 0, color: :white }))
        
        expect(king.castle?(0, 1, board)).to be true
        expect(board.at(0, 2)).to eq Rook.new ({ row: 0, column: 2, color: :white})
      end

      it 'rejects a castle to the right with a piece in the way' do
        board.place(0, 4, king)
        board.place(0, 7, Rook.new({ row: 0, column: 7, color: :white }))
        board.place(0, 5, Bishop.new({ row: 0, column: 5, color: :white }))
        
        expect(king.castle?(0, 6, board)).to be false
      end

      it 'rejects a castle to the right with a moved rook' do
        board.place(0, 4, king)
        rook = Rook.new({ row: 0, column: 7, color: :white })
        rook.moved = true
        board.place(0, 7, rook)
        
        expect(king.castle?(0, 6, board)).to be false
      end

      it 'rejects a castle to the right if intermediate squares can be targeted' do
        board.place(0, 4, king)
        board.place(0, 7, Rook.new({ row: 0, column: 7, color: :white }))
        board.place(2, 7, Bishop.new({ row: 2, column: 6}))

        expect(king.castle?(0, 6, board)).to be false
      end
    end

    context 'black piece' do
      let(:king)    { King.new({ row: 7, column: 4, color: :black })}
      
      it 'accepts a castle to the right' do
        board.place(7, 4, king)
        board.place(7, 7, Rook.new({ row: 7, column: 7, color: :black }))
        
        expect(king.castle?(7, 6, board)).to be true
        expect(board.at(7, 5)).to eq Rook.new ({ row: 7, column: 5, color: :black})
      end

      it 'accepts a castle to the left' do
        board.place(7, 4, king)
        board.place(7, 0, Rook.new({ row: 7, column: 0, color: :black }))
        
        expect(king.castle?(7, 1, board)).to be true
        expect(board.at(7, 2)).to eq Rook.new ({ row: 7, column: 2, color: :black})
      end

      it 'rejects a castle to the right with a piece in the way' do
        board.place(7, 4, king)
        board.place(7, 7, Rook.new({ row: 7, column: 7, color: :black }))
        board.place(7, 5, Bishop.new({ row: 0, column: 5, color: :white }))
        
        expect(king.castle?(0, 6, board)).to be false
      end

      it 'rejects a castle to the right with a moved rook' do
        board.place(7, 4, king)
        rook = Rook.new({ row: 7, column: 7, color: :black })
        rook.moved = true
        board.place(7, 7, rook)
        
        expect(king.castle?(7, 6, board)).to be false
      end

      it 'rejects a castle to the right if intermediate squares can be targeted' do
        board.place(7, 4, king)
        board.place(7, 7, Rook.new({ row: 7, column: 7, color: :black }))
        board.place(5, 4, Bishop.new({ row: 0, column: 5, color: :white }))

        expect(king.castle?(7, 6, board)).to be false
      end
    end
  end
end