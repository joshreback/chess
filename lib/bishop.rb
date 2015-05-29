class Bishop < Piece
  include MoveHelper
  
  @symbol = "B"

  def valid_move?(row, column, board)
    valid_diagonal_move?(row, column, board)
  end
end