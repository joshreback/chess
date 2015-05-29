require 'pry'

class Pawn < Piece
  @symbol = "P"

  def initialize(opts={})
    super
    @start_row = color == :white ? 1 : 6
  end

  def move_type(row, col, board)
    # forward move
    if forward_move?(row, col)
      valid_forward_move?(row, col, board)
    elsif diagonal_move?(row, col)
      diagonal_capture?(row, col, board) || en_passant_capture?(row, col, board)
    else
      false
    end
  end

  def forward_move?(row, col)
    in_front = self.color == :white ? row > self.row : row < self.row
    in_front && col == self.column
  end

  # Side effect of this method is that it updates board's 'en_passant_square'
  # attribute if the pawn moves forward by 2
  def valid_forward_move?(row, col, board)
    num_squares = forward_diff(row)
    case 
    when num_squares == 1
      board.at(row, col).nil?
    when num_squares == 2
      if self.row == @start_row && board.at(row, col).nil?
        ep_row = color == :white ? @start_row + 1 : @start_row - 1
        return { :en_passant_square => Square.new(ep_row, col, color) }
      else
        return false
      end
    else
      false
    end
  end

  def forward_diff(row)
    diff = row - self.row
    diff *= -1 if color == :black
    diff
  end

  def diagonal_move?(row, col)
    ((row - self.row).abs == (col - self.column).abs && 
      (col - self.column).abs == 1)
  end

  def diagonal_capture?(row, col, board)
    (!board.at(row, col).nil? && 
      board.at(row, col).color != self.color)
  end

  def en_passant_capture?(row, col, board)
    en_passant_square = board.en_passant_square
    if (!en_passant_square.nil? && row == en_passant_square.row &&
      col == en_passant_square.column && self.color != en_passant_square.color)
      # Execute the capture
      # If the square that's moving is white, set the square behind it to nil
      if color == :white
        board.place(en_passant_square.row - 1, en_passant_square.column, nil)
      else
        board.place(en_passant_square.row + 1, en_passant_square.column, nil)
      end
      return :en_passant_capture
    else
      return false
    end
  end
end