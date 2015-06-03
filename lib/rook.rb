class Rook < Piece
  include MoveHelper
  
  @symbol = "R"

  def initialize(opts={})
    super
    @moved = false
  end
  
  attr_accessor :checked, :moved

  def move_type(row, column, board)
    valid_lateral_move?(row, column, board) ? { valid: true } : { valid: false }
  end
end