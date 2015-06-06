require 'spec_helper'

describe Board do
  let(:board) { Board.new }
  let(:empty_board) { Board.new(empty=true) }

  describe '#initialize' do
    it 'initializes correct starting configuration' do
      expect(board).to_not be_nil
    end

    it 'initializes default conditions' do
      expect(board.at(0, 0)).to eq Rook.new({row: 0, column: 0, color: :white})
      expect(board.at(7, 7)).to eq Rook.new({row: 7, column: 7, color: :black})
      expect(board.at(4, 5)).to be_nil
      # ... etc
    end
  end

  describe '#get_row' do
    it 'returns row correctly' do
      row = board.get_row(0)
      expect(row[0]).to eq (Rook.new({row: 0, column: 0, color: :white }))

      row = board.get_row(4)
      expect(row). to eq [nil, nil, nil, nil, nil, nil, nil, nil]
    end
  end

  describe '#get_column' do
    it 'returns column correctly' do
      column = board.get_column(0)

      expect(column[0]).to eq Rook.new({ row: 0, column: 0, color: :white })
      expect(column[1]).to eq Pawn.new({ row: 1, column: 0, color: :white })
      expect(column[2]).to be_nil
      expect(column[6]).to eq Pawn.new({ row: 6, column: 0, color: :black })
      expect(column[7]).to eq Rook.new({ row: 7, column: 0, color: :black })
    end
  end

  describe '#get_diagonals' do
    it 'returns both sets of diagonals for a square' do
      diagonals = board.get_diagonals(0, 0)
      left_diagonal = diagonals.first
      right_diagonal = diagonals.last

      expect(left_diagonal.size).to eq 1
      expect(left_diagonal.first).to eq Rook.new({row: 0, column: 0, color: :white})
      
      expect(right_diagonal.size).to eq 8
      expect(right_diagonal[0]).to eq Rook.new({row: 0, column: 0, color: :white})
      expect(right_diagonal[1]).to eq Pawn.new({row: 1, column: 1, color: :white})
      expect(right_diagonal[6]).to eq Pawn.new({row: 6, column: 6, color: :black})
      expect(right_diagonal[7]).to eq Rook.new({row: 7, column: 7, color: :black})
    end

    it 'returns both sets of diagonals for a square in middle of board' do
      diagonals = board.get_diagonals(5, 1)
      left_diagonal = diagonals.first
      right_diagonal = diagonals.last

      expect(left_diagonal.size).to eq 7
      expect(left_diagonal[0]).to eq Knight.new({row: 0, column: 6, color: :white})
      expect(left_diagonal[1]).to eq Pawn.new({row: 1, column: 5, color: :white})
      expect(left_diagonal[6]).to eq Pawn.new({row: 6, column: 0, color: :black})
      
      expect(right_diagonal.size).to eq 4
      expect(right_diagonal[0]).to be_nil
      expect(right_diagonal[1]).to be_nil
      expect(right_diagonal[2]).to eq Pawn.new({row: 6, column: 2, color: :black})
      expect(right_diagonal[3]).to eq Queen.new({row: 7, column: 3, color: :black})
    end
  end

  describe 'king_in_check?' do
    it 'returns false on an empty board' do
      empty_board.place(0, 0, King.new({ row: 0, column: 0, color: :black }))
      expect(empty_board.king_in_check?(:black)).to be false
    end

    it 'returns true when a queen can check' do
      empty_board.place(0, 0, King.new({ row: 0, column: 0, color: :black }))
      empty_board.place(4, 0, Queen.new({ row: 4, column: 0, color: :white }))
      expect(empty_board.king_in_check?(:black)).to be true
    end

    it 'returns true when a rook can check' do
      empty_board.place(0, 0, King.new({ row: 0, column: 0, color: :black }))
      empty_board.place(4, 0, Rook.new({ row: 4, column: 0, color: :white }))
      expect(empty_board.king_in_check?(:black)).to be true

      board.place(0, 0, nil)
      empty_board.place(0, 4, Rook.new({ row: 0, column: 4, color: :white }))
      expect(empty_board.king_in_check?(:black)).to be true
    end

    it 'returns true when a bishop can check' do
      empty_board.place(0, 0, King.new({ row: 0, column: 0, color: :black }))
      empty_board.place(4, 4, Bishop.new({ row: 4, column: 4, color: :white }))
      expect(empty_board.king_in_check?(:black)).to be true
    end

    it 'returns true when a knight can check' do
      empty_board.place(0, 0, King.new({ row: 0, column: 0, color: :black }))
      empty_board.place(2, 1, Knight.new({ row: 2, column: 1, color: :white }))
      expect(empty_board.king_in_check?(:black)).to be true
    end

    it 'several pieces on board, but none can check' do
      empty_board.place(1, 1, King.new({ row: 1, column: 1, color: :black }))
      empty_board.place(5, 4, Bishop.new({ row: 5, column: 4, color: :white }))
      empty_board.place(0, 2, Rook.new({ row: 0, column: 2, color: :white }))
      empty_board.place(6, 4, Queen.new({ row: 6, column: 4, color: :white }))
      expect(empty_board.king_in_check?(:black)).to be false
    end
  end

  describe 'locate_piece' do
    it 'locates the piece to move' do
      expect(board.locate_piece(2, 4)).to eq Pawn.new({row: 1, column: 3, color: :white})
    end

    it 'returns appropriate error when no piece at that square' do
      expect { board.locate_piece(4, 4) }.to raise_error(Board::NoPieceError)
    end

    it 'returns appropriate error when square is out of bounds' do
      expect { board.locate_piece(12, 4) }.to raise_error(Board::IllegalSquareError)
    end
  end

  describe 'make_move' do
    it 'correctly makes move to specified location' do
      piece_to_move = board.locate_piece(2, 4)

      board.make_move(piece_to_move.color, 3, 4)
      
      expect(board.at(1, 3)).to be_nil                      # Piece moved from square
      expect(board.locate_piece(3, 4)).to eq piece_to_move  # Piece moved to square
    end

    it 'correctly makes move to specified location - black piece' do
      piece_to_move = board.locate_piece(7, 4)

      board.make_move(piece_to_move.color, 5, 4)
      
      expect(board.at(6, 3)).to be_nil                      # Piece moved from square
      expect(board.locate_piece(5, 4)).to eq piece_to_move  # Piece moved from square
    end

    it 'correctly executes a castle - white, right' do
      empty_board.place(0, 4, King.new({ row: 0, column: 4, color: :white }))
      empty_board.place(0, 7, Rook.new({ row: 0, column: 7, color: :white }))

      # Creates a scenario like this:
      # 8    |    |    |    |    |    |    |
      # ---------------------------------------
      # 7    |    |    |    |    |    |    |
      #   -------------------------------------
      # 6    |    |    |    |    |    |    |
      #   -------------------------------------
      # 5    |    |    |    |    |    |    |
      #   -------------------------------------
      # 4    |    |    |    |    |    |    |
      #   -------------------------------------
      # 3    |    |    |    |    |    |    |
      #   -------------------------------------
      # 2    |    |    |    |    |    |    |
      #   -------------------------------------
      # 1    |    |    |    | WK |    |    | WR
      #   -------------------------------------
      #   -------------------------------------
      #   1  | 2  | 3  | 4  | 5  | 6  | 7  | 8
            
      empty_board.locate_piece(1, 5)
      empty_board.make_move(:white, 1, 7)

      expect(empty_board.at(0, 6)).to eq King.new({ row: 0, column: 6, color: :white})
      expect(empty_board.at(0, 5)).to eq Rook.new({ row: 0, column: 5, color: :white})
      expect(empty_board.at(0, 7)).to be_nil
    end

    it 'correctly executes a castle - black, left' do
      empty_board.place(7, 4, King.new({ row: 7, column: 4, color: :black }))
      empty_board.place(7, 0, Rook.new({ row: 0, column: 7, color: :black }))

      # Creates a scenario like this:
      # 8 WR |    |    |    | BK |    |    |
      # ---------------------------------------
      # 7    |    |    |    |    |    |    |
      #   -------------------------------------
      # 6    |    |    |    |    |    |    |
      #   -------------------------------------
      # 5    |    |    |    |    |    |    |
      #   -------------------------------------
      # 4    |    |    |    |    |    |    |
      #   -------------------------------------
      # 3    |    |    |    |    |    |    |
      #   -------------------------------------
      # 2    |    |    |    |    |    |    |
      #   -------------------------------------
      # 1    |    |    |    |    |    |    | 
      #   -------------------------------------
      #   -------------------------------------
      #   1  | 2  | 3  | 4  | 5  | 6  | 7  | 8

      empty_board.locate_piece(8, 5)
      empty_board.make_move(:black, 8, 3)

      expect(empty_board.at(7, 2)).to eq King.new({ row: 7, column: 2, color: :black})
      expect(empty_board.at(7, 3)).to eq Rook.new({ row: 7, column: 3, color: :black})
      expect(empty_board.at(7, 0)).to be_nil
    end

    context 'pawn promotion' do
      it 'returns an empty array when no pieces have been captured' do
        promote_pawn = Pawn.new({ row: 6, column: 1, color: :white })
        empty_board.place(6, 1, promote_pawn)

        # Creates a scenario like this:
        # 8    |    |    |    |    |    |    |
        # ---------------------------------------
        # 7    | WP |    |    |    |    |    |
        #   -------------------------------------
        # 6    |    |    |    |    |    |    |
        #   -------------------------------------
        # 5    |    |    |    |    |    |    |
        #   -------------------------------------
        # 4    |    |    |    |    |    |    |
        #   -------------------------------------
        # 3    |    |    |    |    |    |    |
        #   -------------------------------------
        # 2    |    |    |    |    |    |    |
        #   -------------------------------------
        # 1    |    |    |    |    |    |    | 
        #   -------------------------------------
        #   -------------------------------------
        #   1  | 2  | 3  | 4  | 5  | 6  | 7  | 8

        empty_board.locate_piece(7, 2)
        move = empty_board.make_move(:white, 8, 2)

        expect(move).to eq []
      end

      it 'returns proper list of captured pieces' do
        promote_pawn = Pawn.new({ row: 6, column: 1, color: :white })
        empty_board.place(6, 1, promote_pawn)
        empty_board.place(0, 0, Rook.new({row: 0, column: 0, color: :white}))
        empty_board.place(0, 1, Rook.new({row: 0, column: 1, color: :black}))

        # Creates a scenario like this:
        # 8    |    |    |    |    |    |    |
        # ---------------------------------------
        # 7    | WP |    |    |    |    |    |
        #   -------------------------------------
        # 6    |    |    |    |    |    |    |
        #   -------------------------------------
        # 5    |    |    |    |    |    |    |
        #   -------------------------------------
        # 4    |    |    |    |    |    |    |
        #   -------------------------------------
        # 3    |    |    |    |    |    |    |
        #   -------------------------------------
        # 2    |    |    |    |    |    |    |
        #   -------------------------------------
        # 1 WR | BR |    |    |    |    |    | 
        #   -------------------------------------
        #   -------------------------------------
        #   1  | 2  | 3  | 4  | 5  | 6  | 7  | 8

        # Capture the white rook
        empty_board.locate_piece(1, 2)
        empty_board.make_move(:black, 1, 1)

        # Then, promote the pawn
        empty_board.locate_piece(7, 2)
        move = empty_board.make_move(:white, 8, 2)

        expect(move).to eq ["Rook"]
      end
    end

    it 'raises error when trying to make illegal move' do
      piece_to_move = board.locate_piece(2, 4)

      expect {
        board.make_move(piece_to_move.color, 5, 4)  
      }.to raise_error(Board::InvalidMoveError)
      expect(board.locate_piece(2, 4)).to eq piece_to_move
      expect(board.at(4, 3)).to be_nil      
    end

    it 'raises error when the move puts the king in check' do
      empty_board.place(1, 3, Pawn.new({ row: 1, column: 3, color: :white }))
      empty_board.place(0, 4, King.new({ row: 0, column: 4, color: :white }))
      empty_board.place(2, 2, Bishop.new({ row: 2, column: 2, color: :black }))

      # Creates a scenario like this:
      # 8    |    |    |    |    |    |    |
      # ---------------------------------------
      # 7    |    |    |    |    |    |    |
      #   -------------------------------------
      # 6    |    |    |    |    |    |    |
      #   -------------------------------------
      # 5    |    |    |    |    |    |    |
      #   -------------------------------------
      # 4    |    |    |    |    |    |    |
      #   -------------------------------------
      # 3    |    | BB |    |    |    |    |
      #   -------------------------------------
      # 2    |    |    | WP |    |    |    |
      #   -------------------------------------
      # 1    |    |    |    | WK |    |    |
      #   -------------------------------------
      #   -------------------------------------
      #   1  | 2  | 3  | 4  | 5  | 6  | 7  | 8

      piece_to_move = empty_board.locate_piece(2, 4)  # the white pawn      
      expect {
        empty_board.make_move(piece_to_move.color, 3, 4)
      }.to raise_error(Board::KingInCheckError)
      expect(empty_board.locate_piece(2, 4)).to eq piece_to_move
      expect(empty_board.at(2, 3)).to be_nil
    end


    it 'raises an error when the move puts the king in check - another scenario' do
      empty_board.place(0, 0, King.new({ row: 0, column: 0, color: :white }))
      empty_board.place(7, 1, Rook.new({ row: 7, column: 1, color: :black }))

      # Creates a board like this
      # 8    | BR |    |    |    |    |    |
      #   -------------------------------------
      # 7    |    |    |    |    |    |    |
      #   -------------------------------------
      # 6    |    |    |    |    |    |    |
      #   -------------------------------------
      # 5    |    |    |    |    |    |    |
      #   -------------------------------------
      # 4    |    |    |    |    |    |    |
      #   -------------------------------------
      # 3    |    |    |    |    |    |    |
      #   -------------------------------------
      # 2    |    |    |    |    |    |    |
      #   -------------------------------------
      # 1 WK |    |    |    |    |    |    |
      #   -------------------------------------
      #   -------------------------------------
      #   1  | 2  | 3  | 4  | 5  | 6  | 7  | 8
      
      piece_to_move = empty_board.locate_piece(1, 1)  # The white king
      expect {
        empty_board.make_move(piece_to_move.color, 1, 2)
      }.to raise_error(Board::KingInCheckError)
      expect(empty_board.locate_piece(1, 1)).to eq piece_to_move      
      expect(empty_board.at(0, 1)).to be_nil
    end
  end

  describe 'identify_check_squares' do
    it 'identifies intermediate squares between king and rook' do
      king = King.new({ row: 0, column: 0, color: :white })
      empty_board.place(0, 0, king)
      rook = Rook.new({ row: 5, column: 0, color: :black })
      empty_board.place(5, 0, rook)

      # Creates a board like this
      # 8    |    |    |    |    |    |    |
      #   -------------------------------------
      # 7    |    |    |    |    |    |    |
      #   -------------------------------------
      # 6 BR |    |    |    |    |    |    |
      #   -------------------------------------
      # 5    |    |    |    |    |    |    |
      #   -------------------------------------
      # 4    |    |    |    |    |    |    |
      #   -------------------------------------
      # 3    |    |    |    |    |    |    |
      #   -------------------------------------
      # 2    |    |    |    |    |    |    |
      #   -------------------------------------
      # 1 WK |    |    |    |    |    |    |
      #   -------------------------------------
      #   -------------------------------------
      #   1  | 2  | 3  | 4  | 5  | 6  | 7  | 8

      check_squares = empty_board.identify_check_squares(rook, king)
      expect(check_squares.size).to eq 4
      expect(check_squares).to include [1, 0]
      expect(check_squares).to include [2, 0]
      expect(check_squares).to include [3, 0]
      expect(check_squares).to include [4, 0]
    end
  end








end