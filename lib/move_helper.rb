require 'pry'
require_relative './board.rb'

module MoveHelper
  def valid_lateral_move?(row, column, board)
    return false if self.row != row and self.column != column

    if self.row != row
      line = board.get_column(column)
      direction = :row
      other_square = row
    else
      line = board.get_row(row)
      direction = :column
      other_square = column
    end
    my_square    = self.send(direction)
    move_squares = extract_move_squares(line, my_square, other_square)

    return validity(move_squares)
  end

  def valid_diagonal_move?(row, column, board)
    return false if ((row - self.row).abs != (column - self.column).abs || row == self.row)
    
    diagonals = board.get_diagonals(self.row, self.column)
    diagonal = including_diagonal(diagonals, row, column)
    
    diff = (row - self.row).abs
    direction = row > self.row ? 1 : -1  # traverse forward or backward
    diff *= direction
    my_location = diagonal.index(self)
    other_location = my_location + diff
    move_squares = extract_move_squares(diagonal, my_location, other_location)
    
    return validity(move_squares)
  end

  def extract_move_squares(line, my_square, other_square)
    if other_square > my_square
      line = line[my_square + 1..other_square]
    else
      line = line[other_square..my_square - 1].reverse
    end
    line
  end

  def including_diagonal(diagonals, row, column)
    case
    when row > self.row && column > self.column then return diagonals.last
    when row < self.row && column > self.column then return diagonals.first 
    when row > self.row && column < self.column then return diagonals.first
    when row < self.row && column < self.column then return diagonals.last
    end
  end

  def validity(move_squares)
    case
    when is_empty?(move_squares) || is_capture?(move_squares) then true
    else false
    end
  end

  def is_empty?(move)
    move.compact.size == 0
  end

  def is_capture?(move)
    move.compact.size == 1 && !move.last.nil? && move.last.color != self.color
  end
end