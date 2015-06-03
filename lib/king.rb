require 'pry'

class King < Piece
  
  @symbol = "K"
  CAN_COVER = 1

  def initialize(opts={})
    super
    @moved = false
    @checked = false
  end

  attr_accessor :checked, :moved

  def move_type(row, column, board)
    legal = diagonal?(row, column, CAN_COVER) || straight?(row, column, CAN_COVER)
    return {valid: false} if !legal

    if empty_square?(row, column, board) || capture?(row, column, board)
      { valid: true }
    else
      { valid: false }
    end
  end

  def diagonal?(row, column, can_cover=false)
    diag = (row - self.row).abs == (column - self.column).abs
    diag &&= (row - self.row).abs == can_cover if !can_cover
    diag
  end

  def straight?(row, column, can_cover=false)
    straight = (self.row == row) ^ (self.column == column)
    return false if !straight
    return true if !can_cover

    if self.row != row
      diff = (self.row - row).abs
    else
      diff = (self.column - column).abs
    end
    diff == can_cover
  end

  def empty_square?(row, column, board)
    board.at(row, column).nil?
  end
  
  def capture?(row, column, board)
    board.at(row, column).color != self.color
  end

  def castle?(row, column, board)
    return false if moved == true or checked == true

    castle_type = determine_castle_type(row, column)
    return false if castle_type.nil?

    rook = determine_rook(board, castle_type)
    return false if rook.moved or rook.color != color
    
    castle_columns = determine_castle_columns(castle_type)
    castle_squares = castle_columns.map { |c| board.at(row, c) }
    return false if !castle_squares.compact.empty? or castling_through_check?(board, castle_columns)

    if castle_type == :left
      board.place(rook.row, rook.column, nil)
      board.place(row, 2, rook)
    else
      board.place(rook.row, rook.column, nil)
      board.place(row, 5, rook)
    end

    return true
  end

  private

  def determine_castle_type(row, column)
    case
    when row == self.row && column - self.column == 2
      :right
    when row == self.row && self.column - column == 3
      :left
    else
      nil
    end
  end

  def determine_castle_columns(castle_type)
    if castle_type == :right
      [column + 1, column + 2]
    else
      [column - 1, column - 2, column - 3]
    end
  end

  def determine_rook(board, castle_type)
    castle_type == :right ? board.at(row, column + 3) : board.at(row, column - 4)
  end

  def castling_through_check?(board, castle_columns)
    castle_columns.any? { |c| board.can_target?(self.color, self.row, c) }
  end
end