require 'pry'

class Game

  class InvalidInputError < StandardError; end
  
  def initialize
    @players = [:white, :black].cycle
    @board = Board.new()
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
      x, y = response.first.to_i, response.last.to_i
      move = board.make_move(current_player, x, y)
      handle_promoted_pawn(move) if move.is_a?(:Array)
    rescue Board::InvalidMoveError => e
      puts e.message
      retry
    end
  end

  def handle_promoted_pawn(captured_pieces)
    puts "You have promoted a pawn! Please select the piece you'd like to promote to..."
    begin
      captured_pieces.each_with_index { |piece, index| puts "#{index}: #{piece}" }
      response = gets.chomp.to_i
      acceptable_choices = (0..captured_pieces.length - 1).to_a 
      raise InvalidInputError if !acceptable_choices.include?(response)
    rescue InvalidInputError
      puts "That is not a valid input"
    else
      board.captured_pieces[current].delete_at(response)
    end
  end
end