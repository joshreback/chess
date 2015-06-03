class Bishop < Piece
  include MoveHelper
  
  @symbol = "B"

  def move_type(row, column, board)
    valid_diagonal_move?(row, column, board) ? { valid: true} : { valid: false }
  end
end