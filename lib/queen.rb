require 'pry'

class Queen < Piece
  include MoveHelper

  @symbol = "Q"

  def valid_move?(row, column, board)
    valid_diagonal_move?(row, column, board) || valid_lateral_move?(row, column, board)
  end
end