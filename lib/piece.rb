class Piece
  def initialize(opts={})
    @row, @column, @color  = opts[:row], opts[:column], opts[:color]
  end

  Square = Struct.new(:row, :column, :color)  # color of pawn that exposed the square
  attr_accessor :row, :column, :color

  class << self
    attr_reader :symbol
  end

  def ==(piece)
    (self.class.name == piece.class.name &&
      self.row == piece.row &&
      self.column == piece.column &&
      self.color == piece.color)
  end

  def to_s
    " #{color[0].upcase}#{self.class.symbol} "
  end

  def update!(row, column)
    self.row, self.column = row, column
  end
end