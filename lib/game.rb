require 'pry'

class Game
  def initialize
    @players = [:white, :black].cycle
    @board = Board.new
  end

  attr_accessor :current_player, :board

  def start_new_turn
    @current_player = @players.next
  end

  def play
    loop do
      start_new_turn()
      puts board
      puts "\n\n#{current_player}'s turn...\n"
      make_move()
    end
  end

  def get_piece_to_move
    begin
      print "Enter x, y of piece to move >>"
      response = gets.chomp.split(",")
      # response = [3, 4]
      x, y = response.first.to_i, response.last.to_i
      board.locate_piece(x, y)
    rescue Board::IllegalSquareError, Board::NoPieceError => e
      puts e.message
      retry
    end
  end

  def make_move
    get_piece_to_move()
    begin
      print "Enter x, y of square to move to >>"
      response = gets.chomp.split(",")
      # response = [3, 4]
      x, y = response.first.to_i, response.last.to_i
      board.make_move(current_player, x, y)
    rescue Board::InvalidMoveError => e
      puts e.message
      retry
    end
  end
end