require 'spec_helper'
require 'pry'

describe Pawn do
  let(:board) { Board.new(empty=true) }

  describe 'move_type' do
    context 'white' do

      context 'normal functionality' do
        let(:pawn)    { Pawn.new({ row: 1, column: 1, :color => :white }) }
        before(:each) { board.place(1, 1, pawn) }

        it 'accepts one forward onto empty square' do
          expect(pawn.move_type(2, 1, board)[:valid]).to be true
        end

        it 'accepts two forward from start onto empty square' do
          expect(pawn.move_type(3, 1, board)[:valid]).to be true
        end

        it 'rejects two forward from non-start onto empty square' do
          pawn.row = 2 
          board.place(2, 1, pawn)
          expect(pawn.move_type(4, 1, board)[:valid]).to be false
        end

        it 'rejects three forward' do
          expect(pawn.move_type(6, 1, board)[:valid]).to be false
        end

        it 'rejects one forward onto occupied square' do
          board.place(2, 1, Pawn.new({row: 2, col: 1 }))

          expect(pawn.move_type(2, 1, board)[:valid]).to be false
        end

        it 'rejects backwards moves' do
          expect(pawn.move_type(0, 1, board)[:valid]).to be false
        end

        it 'rejects lateral moves' do
          expect(pawn.move_type(1, 2, board)[:valid]).to be false
        end

        it 'rejects 1 square diagonals onto empty squares' do
          expect(pawn.move_type(2, 2, board)[:valid]).to be false
        end

        it 'allows 1 square diagonal captures' do
          board.place(2, 2, Pawn.new({row: 2, col: 2, :color => :black }))
          expect(pawn.move_type(2, 2, board)[:valid]).to be true
        end

        it 'rejects 1 square diagonals onto squares occupied by same color' do
          board.place(2, 1, Pawn.new({row: 2, col: 2, :color => :white }))
          expect(pawn.move_type(2, 2, board)[:valid]).to be false
        end
      end

      context 'en passant' do
        let(:capturing_pawn) { Pawn.new({ row: 4, column: 4, color: :white }) }
        
        def execute_en_passant_setup
          board.place(4, 4, capturing_pawn)
          board.place(6, 3, Pawn.new({ row: 6, column: 3, color: :black }))

          board.locate_piece(7, 4)        # locate the black pawn
          board.make_move(:black, 5, 4)   # makes the move
        end

        it 'returns the exposed en passant square' do
          pawn = Pawn.new({ row: 6, column: 3, color: :black })
          board.place(6, 3, pawn)

          square = pawn.move_type(4, 3, board)[:exposed_en_passant_square]
          expect(square).to_not be_nil
          expect(square.row).to eq 5
          expect(square.column).to eq 3
          expect(square.color).to eq :black
        end

        it 'sets board en passant square on 2 moves forward' do
          execute_en_passant_setup()
          square = board.exposed_en_passant_square
          expect(square.row).to eq 5
          expect(square.column).to eq 3
          expect(square.color).to eq :black
        end

        it 'accepts a valid en passant capture' do
          execute_en_passant_setup()
          expect(capturing_pawn.en_passant_capture?(5, 3, board)).to eq true
        end

        it 'executes a valid en passant capture' do
          execute_en_passant_setup()
          board.locate_piece(5, 5)          # Locate the white piece
          board.make_move(:white, 6, 4)     # Move the white piece to the en passant square
          binding.pry
          
          expect(board.at(5, 3)).to eq capturing_pawn  # Capturing pawn moved          
          expect(board.at(4, 3)).to be_nil             # Black pawn was captured 
        end

        it 'rejects an invalid en passant capture - capturing pawn moved too late' do
          en_passanted_pawn = Pawn.new({ row: 6, column: 3, color: :black })
          board.place(4, 4, capturing_pawn)
          board.place(6, 3, en_passanted_pawn)

          board.locate_piece(7, 4)        # locate the black pawn
          board.make_move(:black, 6, 4)   # makes a move 1 square forward

          board.locate_piece(6, 4)        # locate the black pawn
          board.make_move(:black, 5, 4)   # make another move one square forward

          expect(!!capturing_pawn.en_passant_capture?(5, 3, board)).to eq false
        end
      end
    end

    context 'black' do
      context 'normal_functionality' do
        let(:pawn) { Pawn.new({ row: 6, column: 1, :color => :black }) }
        before(:each) { board.place(6, 1, pawn) }

        it 'accepts one forward onto empty square' do
          expect(pawn.move_type(5, 1, board)[:valid]).to be true
        end

        it 'accepts two forward from start onto empty square' do
          expect(!!pawn.move_type(4, 1, board)[:valid]).to be true
        end

        it 'rejects two forward from non-start onto empty square' do
          pawn.row = 5
          board.place(5, 1, pawn)
          expect(pawn.move_type(3, 1, board)[:valid]).to be false
        end

        it 'rejects three forward' do
          expect(pawn.move_type(3, 1, board)[:valid]).to be false
        end

        it 'rejects one forward onto occupied square' do
          board.place(5, 1, Pawn.new({row: 5, col: 1 })[:valid])

          expect(pawn.move_type(5, 1, board)[:valid]).to be false
        end

        it 'rejects backwards moves' do
          expect(pawn.move_type(7, 1, board)[:valid]).to be false
        end

        it 'rejects lateral moves' do
          expect(pawn.move_type(6, 2, board)[:valid]).to be false
        end

        it 'rejects 1 square diagonals onto empty squares' do
          expect(pawn.move_type(5, 2, board)[:valid]).to be false
        end

        it 'allows 1 square diagonal captures' do
          board.place(5, 2, Pawn.new({row: 5, col: 2, :color => :white }))
          expect(pawn.move_type(5, 2, board)[:valid]).to be true
        end

        it 'rejects 1 square diagonals onto squares occupied by same color' do
          board.place(5, 2, Pawn.new({row: 5, col: 2, :color => :black }))
          expect(pawn.move_type(5, 2, board)[:valid]).to be false
        end
      end

      context 'en_passant' do
        let(:capturing_pawn) { Pawn.new({ row: 3, column: 3, color: :black }) }
        
        def execute_en_passant_setup
          board.place(3, 3, capturing_pawn)
          board.place(1, 4, Pawn.new({ row: 1, column: 4, color: :white }))

          board.locate_piece(2, 5)        # locate the white pawn
          board.make_move(:white, 4, 5)   # makes the move
        end

        it 'sets board en passant square on 2 moves forward' do
          execute_en_passant_setup()
          square = board.exposed_en_passant_square
          expect(square.row).to eq 2
          expect(square.column).to eq 4
          expect(square.color).to eq :white
        end

        it 'accepts a valid en passant capture' do
          execute_en_passant_setup()
          expect(!!capturing_pawn.en_passant_capture?(2, 4, board)[:valid]).to eq true
        end

        it 'executes a valid en passant capture' do
          execute_en_passant_setup()

          board.locate_piece(4, 4)          # Locate the black piece
          board.make_move(:black, 3, 5)     # Move the black piece to the en passant square

          expect(board.at(2, 4)[:valid]).to eq capturing_pawn  # Capturing pawn moved
          expect(board.at(3, 4)[:valid]).to be_nil             # White pawn was captured 
        end

        it 'rejects an invalid en passant capture - capturing pawn moved too late' do
          en_passanted_pawn = Pawn.new({ row: 1, column: 4, color: :white })
          board.place(3, 3, capturing_pawn)
          board.place(1, 4, en_passanted_pawn)

          board.locate_piece(2, 5)        # locate the white pawn
          board.make_move(:white, 3, 5)   # makes a move 1 square forward

          board.locate_piece(3, 5)        # locate the black pawn
          board.make_move(:white, 4, 5)   # make another move one square forward

          expect(!!capturing_pawn.en_passant_capture?(2, 4, board)).to eq false
        end
      end
    end
  end  
end