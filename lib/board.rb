require 'pry'
class Board
  ROWS = 8
  COLUMNS = 8

  class NoPieceError < StandardError; end
  class IllegalSquareError < StandardError; end
  class InvalidMoveError < StandardError; end
  class KingInCheckError < StandardError; end

  def initialize(empty=false)
    self.contents = empty ? empty_board() : starting_state()
  end

  attr_accessor :contents, :en_passant_square, :piece_to_move

  def to_s
    output = ""
    line_break = "\n  -------------------------------------\n"

    # pieces
    contents.reverse.each_with_index do |pieces, row|
      output << "#{ROWS - row}" + pieces.map do |piece|
        piece ? piece.to_s  : "    "
      end.join("|") + line_break
    end

    output += "  -------------------------------------\n"
    output += "  1  | 2  | 3  | 4  | 5  | 6  | 7  | 8  "
    output
  end

  def place(row, col, piece)
    contents[row][col] = piece
    piece.update!(row, col) if !piece.nil?
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
    lower_left = get_partial_diagonal(row, :-, column, :+).reverse  
    upper_left = get_partial_diagonal(row, :+, column, :-)
    left = (lower_left + [contents[row][column]] + upper_left)

    lower_right = get_partial_diagonal(row, :-, column, :-).reverse  
    upper_right = get_partial_diagonal(row, :+, column, :+)
    right = (lower_right + [contents[row][column]] + upper_right)
    return [left, right]
  end

  def king_in_check?(player)    
    king = find_players_king(player)
    return king ? can_target?(player, king.row, king.column) : false  # only occurs in testing
  end

  # Side effect of locate_piece is that it assigns the
  # piece that's going to be moved.
  def locate_piece(display_row, display_column)
    row, column = sanitize_input(display_row, display_column)
    begin
      self.piece_to_move = at(row, column)
    rescue NoMethodError
      raise IllegalSquareError, "That square is outside the board"
    end    
    raise NoPieceError, "That square is unoccupied" if !piece_to_move
    piece_to_move
  end

  # Need to be less coupling between board & piece
  # These refactors will be made then
  def make_move(current_player, display_row, display_column)    
    row, column = sanitize_input(display_row, display_column)
    king = find_players_king(current_player)
    king.checked = true if king && can_target?(current_player, king.row, king.column)

    # Store attributes to be able to revert move if necessary
    original_row    = piece_to_move.row
    original_column = piece_to_move.column
    original_player = piece_to_move.color
    
    move_to_make = piece_to_move.move_type(row, column, self)    
    if !move_to_make
      raise InvalidMoveError, "That is an illegal move"
    elsif move_to_make == true
      self.en_passant_square = nil
      place(original_row, original_column, nil)
      place(row, column, piece_to_move)
    elsif move_to_make == :en_passant_capture
      place(original_row, original_column, nil)
      place(row, column, piece_to_move)
    elsif move_to_make.has_key?(:en_passant_square)
      self.en_passant_square = move_to_make[:en_passant_square]
      place(original_row, original_column, nil)
      place(row, column, piece_to_move)
    end
    
    if !king.nil? && king_in_check?(original_player)
      # restore original positions
      place(original_row, original_column, piece_to_move)
      place(row, column, nil)
      raise KingInCheckError
    end    

    piece = self.at(row, column)
    piece.moved = true if piece.is_a?(King) or piece.is_a?(Rook)
  end

  def can_target?(player, target_row, target_column)
    can_target = false
    traverse_board(Proc.new do |piece|      
      if piece.is_a?(Piece) && piece.color != player
        can_target = true if piece.move_type(target_row, target_column, self)
      end
    end)    
    !!can_target
  end

  private

  def starting_state
    default = [
      ['Rook', 'Knight', 'Bishop', 'Queen', 'King', 'Bishop', 'Knight', 'Rook'],
      ['Pawn', 'Pawn', 'Pawn', 'Pawn', 'Pawn', 'Pawn', 'Pawn', 'Pawn'],
      [nil, nil, nil, nil, nil, nil, nil, nil],
      [nil, nil, nil, nil, nil, nil, nil, nil],
      [nil, nil, nil, nil, nil, nil, nil, nil],
      [nil, nil, nil, nil, nil, nil, nil, nil],
      ['Pawn', 'Pawn', 'Pawn', 'Pawn', 'Pawn', 'Pawn', 'Pawn', 'Pawn'],
      ['Rook', 'Knight', 'Bishop', 'Queen', 'King', 'Bishop', 'Knight', 'Rook']
    ]

    default.each_with_index do |piece_row, row|
      piece_row.each_with_index do |piece, column|
        if piece.class.name == "String"
          color = row < ROWS/2 ? :white : :black
          default[row][column] = Object::const_get(piece).new({row: row, column: column, color: color })
        end
      end
    end
    default
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

  def get_partial_diagonal(row, row_direction, column, column_direction)
    row_limit        = row_direction == :+ ? ROWS : 0
    row_operator     = row_direction == :+ ? :< : :>=
    column_limit     = column_direction == :+ ? COLUMNS : 0
    column_operator  = column_direction == :+ ? :< : :>=
    
    # Do not include the current square
    row              = row.send(row_direction, 1)
    column           = column.send(column_direction, 1) 
    section          = []

    while (row.send(row_operator, row_limit) and
      column.send(column_operator, column_limit)) do
      section << contents[row][column]
      row = row.send(row_direction, 1)
      column = column.send(column_direction, 1)
    end
    return section
  end

  def traverse_board(code)
    contents.each do |row|
      row.each do |piece|
        code.call(piece)
      end
    end
  end

  def find_players_king(player)
    king = nil
    traverse_board(Proc.new do |piece|
      king = piece if piece.is_a?(King) && piece.color == player
    end)
    king
  end

  def sanitize_input(row, column)
    return row - 1, column - 1
  end
end