class Knight < Piece
  @symbol = "N"

  def valid_move?(row, column, board)
    legal = false
    legal ||= (self.row - row).abs == 2 && (self.column - column).abs == 1
    legal ||= (self.row - row).abs == 1 && (self.column - column).abs == 2
    return false if !legal
    
    empty_square?(row, column, board) || capture?(row, column, board)
  end

  def empty_square?(row, column, board)
    board.at(row, column).nil?
  end
  
  def capture?(row, column, board)
    board.at(row, column).color != self.color
  end
end