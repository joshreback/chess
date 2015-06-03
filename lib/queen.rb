require 'pry'

class Queen < Piece
  include MoveHelper

  @symbol = "Q"

  def move_type(row, column, board)
    if valid_diagonal_move?(row, column, board) || valid_lateral_move?(row, column, board)
      { valid: true }
    else
      { valid: false }
    end
  end
end