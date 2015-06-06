require 'spec_helper'

describe Game do
  let(:game) { Game.new }

  describe 'start_new_turn' do
    it 'assigns :white as first plaer' do
      game.start_new_turn()

      expect(game.current_player).to eq :white
    end

    it 'assigns :black as first plaer' do
      game.start_new_turn()
      game.start_new_turn()

      expect(game.current_player).to eq :black
    end
  end

  describe 'get_piece_to_move' do
    it 'raises no error when piece to move is valid' do
      allow(game).to receive(:gets).and_return("2, 2")
      game.start_new_turn()

      expect { 
        game.get_piece_to_move
      }.not_to raise_error
    end

    it 'rescues error when user enters an illegal square' do
      allow(game).to receive(:gets).and_return("9, 2", "2, 2")

      game.start_new_turn()

      expect { 
        game.get_piece_to_move
      }.to output(/That square is outside the board/).to_stdout
    end

    it 'rescues error when user enters an unoccupied square' do
      allow(game).to receive(:gets).and_return("4, 4", "2, 2")

      game.start_new_turn()

      expect { 
        game.get_piece_to_move
      }.to output(/That square is unoccupied/).to_stdout
    end
  end

  describe 'make_move' do
    it 'makes move when valid' do
      allow(game).to receive(:gets).and_return("2, 2", "4, 2")
      game.start_new_turn()

      game.make_move()
       
      expect(game.board.locate_piece(4, 2)).to eq Pawn.new({ row: 3, column: 1, color: :white })
    end

    it 'raises an error when user tries to make an invalid move' do
      allow(game).to receive(:gets).and_return("2, 2", "5, 2", "4, 2")
      game.start_new_turn()

      expect {
        game.make_move()  
      }.to output(/That is an illegal move/).to_stdout
    end
  end
end