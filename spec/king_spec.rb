require 'pry'

describe King do
  let(:board) { Board.new(empty=true) }

  describe 'all_possible_moves' do
    it 'returns all possible rows/columns' do
      king = King.new({ row: 3, column: 3, color: :white })
      board.place(3, 3, king)
      
      moves = king.all_possible_moves(board)

      expect(moves.size).to eq 8
      expect(moves).to include [3, 4]
      expect(moves).to include [3, 2]
      expect(moves).to include [4, 3]
      expect(moves).to include [2, 3]  
      expect(moves).to include [4, 4]
      expect(moves).to include [2, 2]
      expect(moves).to include [4, 2]
      expect(moves).to include [2, 4]
    end

    it 'excludes squares which are occupied by same colored piece' do
      king = King.new({ row: 3, column: 3, color: :white })
      board.place(3, 3, king)
      board.place(3, 4, Pawn.new({ row: 3, column: 4, color: :white }))
      board.place(4, 4, Pawn.new({ row: 4, column: 4, color: :white }))
      
      moves = king.all_possible_moves(board)

      expect(moves.size).to eq 6
      expect(moves).to include [3, 2]
      expect(moves).to include [4, 3]
      expect(moves).to include [2, 3]
      expect(moves).to include [2, 2]
      expect(moves).to include [4, 2]
      expect(moves).to include [2, 4]
    end

    it 'excludes squares which are outside by same colored piece' do
      king = King.new({ row: 3, column: 3, color: :white })
      board.place(3, 3, king)
      board.place(3, 4, Pawn.new({ row: 3, column: 4, color: :white }))
      board.place(4, 4, Pawn.new({ row: 4, column: 4, color: :white }))
      
      moves = king.all_possible_moves(board)

      expect(moves.size).to eq 6
      expect(moves).to include [3, 2]
      expect(moves).to include [4, 3]
      expect(moves).to include [2, 3]
      expect(moves).to include [2, 2]
      expect(moves).to include [4, 2]
      expect(moves).to include [2, 4]
    end

    it 'does not exclude squares occupied by opposite colored pieces' do
      king = King.new({ row: 0, column: 3, color: :white })
      board.place(0, 3, king)
      
      moves = king.all_possible_moves(board)

      expect(moves.size).to eq 5
      expect(moves).to include [0, 2]
      expect(moves).to include [0, 4]
      expect(moves).to include [1, 2]
      expect(moves).to include [1, 3]  
      expect(moves).to include [1, 4]
    end
  end

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
      end

      it 'accepts a castle to the left' do
        board.place(0, 4, king)
        board.place(0, 0, Rook.new({ row: 0, column: 0, color: :white }))
        
        expect(king.castle?(0, 1, board)).to be true
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
      end

      it 'accepts a castle to the left' do
        board.place(7, 4, king)
        board.place(7, 0, Rook.new({ row: 7, column: 0, color: :black }))
        
        expect(king.castle?(7, 1, board)).to be true
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