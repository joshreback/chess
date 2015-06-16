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

  def determine_check_squares(row, column, board)    
    if self.row != row && self.column != column
      opts = {
        direction: :diagonal,
        square1_row: row,
        square1_column: column,
        square2_row: self.row,
        square2_column: self.column
      }

    elsif self.row != row
      opts = {
        direction: :row,
        square1_row: [row, self.row].min,
        square2_row: [row, self.row].max,
        column: column 
      }
    else
      opts = {
        direction: :column,
        square1_column: [column, self.column].min,
        square2_column: [column, self.column].max,
        row: row 
      }
    end
    move_squares = extract_check_squares(opts)
    move_squares
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

  def extract_check_squares(opts)    
    if opts[:direction] == :diagonal
      if opts[:square1_row] > opts[:square2_row]
        rows = (opts[:square1_row]-1).downto(opts[:square2_row]+1).to_a
      else
        rows = (opts[:square1_row]+1).upto(opts[:square2_row]-1).to_a
      end

      if opts[:square1_column] > opts[:square2_column]
        columns = (opts[:square1_column]-1).downto(opts[:square2_column]+1).to_a
      else
        columns = (opts[:square1_column]+1).upto(opts[:square2_column]-1).to_a
      end
      squares = rows.zip(columns)
    elsif opts[:direction] == :row
      squares = ((opts[:square1_row]+1)...opts[:square2_row]).collect do |row|
        [row, opts[:column]]
      end
    elsif opts[:direction] == :column
      squares = ((opts[:square1_column]+1)...opts[:square2_column]).collect do |col|
        [opts[:row], col]
      end
    end
    return squares
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
    is_empty?(move_squares) || is_capture?(move_squares)
  end

  def is_empty?(move)
    move.compact.size == 0
  end

  def is_capture?(move)
    move.compact.size == 1 && !move.last.nil? && move.last.color != self.color
  end
end