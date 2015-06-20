require_relative 'lib/move_helper'
require_relative 'lib/piece'
require_relative 'lib/game'

Dir.glob("lib/**").each do |file|
  require_relative file
end

game = Game.new
game.play()

# http://stackoverflow.com/questions/30254959/difference-between-classes-and-constants-in-ruby-w-r-t-const-get