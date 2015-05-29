require 'pry'
class Board
  ROWS = 8
  COLUMNS = 8

  class NoPieceError < StandardError; end
  class IllegalSquareError < StandardError; end
  class InvalidMoveError < StandardError; end
  class KingInCheckError < StandardError; end

  def initialize(empty=false)
    @contents = empty ? empty_board() : starting_state()
  end

  attr_reader :contents, :piece_to_move
  attr_accessor :en_passant_square

  def starting_state
    contents = 
    [
      ['Rook', 'Knight', 'Bishop', 'Queen', 'King', 'Bishop', 'Knight', 'Rook'],
      ['Pawn', 'Pawn', 'Pawn', 'Pawn', 'Pawn', 'Pawn', 'Pawn', 'Pawn'],
      [nil, nil, nil, nil, nil, nil, nil, nil],
      [nil, nil, nil, nil, nil, nil, nil, nil],
      [nil, nil, nil, nil, nil, nil, nil, nil],
      [nil, nil, nil, nil, nil, nil, nil, nil],
      ['Pawn', 'Pawn', 'Pawn', 'Pawn', 'Pawn', 'Pawn', 'Pawn', 'Pawn'],
      ['Rook', 'Knight', 'Bishop', 'Queen', 'King', 'Bishop', 'Knight', 'Rook']
    ]

    contents.each_with_index do |piece_row, row|
      piece_row.each_with_index do |piece, column|
        if !piece.nil?
          color = row < 4 ? :white : :black
          contents[row][column] = Object::const_get(piece).new({row: row, column: column, color: color })
        end
      end
    end
    contents
  end

  def empty_board
    [
      [nil, nil, nil, nil, nil, nil, nil, nil],
      [nil, nil, nil, nil, nil, nil, nil, nil],
      [nil, nil, nil, nil, nil, nil, nil, nil],
      [nil, nil, nil, nil, nil, nil, nil, nil],
      [nil, nil, nil, nil, nil, nil, nil, nil],
      [nil, nil, nil, nil, nil, nil, nil, nil],
      [nil, nil, nil, nil, nil, nil, nil, nil],
      [nil, nil, nil, nil, nil, nil, nil, nil]
    ]
  end

  def to_s
    output = ""
    line_break = "\n  -------------------------------------\n"
    # pieces
    contents.reverse.each_with_index do |pieces, row|
      output << "#{ROWS - row}" + pieces.map { |piece| piece ? piece.to_s  : "    " }.join("|") + line_break
    end

    output += "  -------------------------------------\n"
    output += "  1  | 2  | 3  | 4  | 5  | 6  | 7  | 8  "
    output
  end

  def place(row, col, piece)
    contents[row][col] = piece
    if !piece.nil?
      piece.row = row
      piece.column = col
    end
  end

  def at(row, col)
    contents[row][col]
  end

  def get_row(row)
    contents[row]
  end

  def get_column(column)
    contents.reduce([]) { |col, pieces| col << pieces[column] }
  end

  def get_diagonals(row, column)
    diagonals = []

    # left
    upper_left = []
    r = row + 1
    c = column - 1
    while r < ROWS and c >= 0 do
      upper_left << contents[r][c]
      r += 1; c -= 1
    end

    r = row - 1
    c = column + 1
    lower_left = []
    while r >= 0 and c < COLUMNS do
      lower_left.unshift(contents[r][c])
      r -= 1; c += 1
    end
    left = (lower_left + [contents[row][column]] + upper_left)

    # right
    upper_right = []
    r = row + 1
    c = column + 1
    while r < ROWS and c < COLUMNS do
      upper_right << contents[r][c]
      r += 1; c += 1
    end

    r = row - 1
    c = column - 1
    lower_right = []
    while r >= 0 and c >= 0 do
      lower_right.unshift(contents[r][c])
      r -= 1; c -= 1
    end

    right = (lower_right + [contents[row][column]] + upper_right)
    return [left, right]
  end

  def king_in_check?(player)    
    king = find_players_king(player)
    return can_be_targeted?(player, king.row, king.column)
  end

  def find_players_king(player)
    contents.each do |row|
      row.each do |piece|
        if !piece.nil?
          if piece.class.symbol == "K" && piece.color == player
            return piece
          end
        end
      end
    end
    return nil
  end

  def can_be_targeted?(player, target_row, target_column)
    contents.each do |row|
      row.each do |piece|
        if !piece.nil? && piece.color != player
          return true if piece.valid_move?(target_row, target_column, self)
        end
      end
    end

    return false
  end

  # Side effect of locate_piece is that it assigns the
  # piece that's going to be moved.
  def locate_piece(row, column)
    begin
      @piece_to_move = at(row - 1, column - 1)
    rescue NoMethodError
      raise IllegalSquareError, "That square is outside the board"
    end
    raise NoPieceError, "That square is unoccupied" if @piece_to_move.nil?
    @piece_to_move
  end

  def make_move(current_player, row, column)
    king = find_players_king(current_player)
    if !king.nil?
      king.checked = true if can_be_targeted?(current_player, king.row, king.column)
    end

    # Store attributes to be able to revert move if necessary
    original_row    = piece_to_move.row
    original_column = piece_to_move.column
    original_player = piece_to_move.color
    
    move_to_make = piece_to_move.valid_move?(row - 1, column - 1, self)    
    if !move_to_make
      raise InvalidMoveError, "That is an illegal move"
    elsif move_to_make == true
      self.en_passant_square = nil
      place(original_row, original_column, nil)
      place(row - 1, column - 1, piece_to_move)
    elsif move_to_make == :en_passant_capture
      place(original_row, original_column, nil)
      place(row - 1, column - 1, piece_to_move)
    elsif move_to_make.has_key?(:en_passant_square)
      self.en_passant_square = move_to_make[:en_passant_square]
      place(original_row, original_column, nil)
      place(row - 1, column - 1, piece_to_move)
    end
    
    if !king.nil? && king_in_check?(original_player)
      # restore original positions
      place(original_row, original_column, piece_to_move)
      place(row - 1, column -1, nil)
      raise KingInCheckError
    end    

    piece = self.at(row - 1, column - 1)
    piece.moved = true if piece.class.symbol == "K" or piece.class.symbol == "R"
  end
end