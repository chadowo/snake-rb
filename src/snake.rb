require 'gosu' unless RUBY_ENGINE == 'mruby'

$: << 'src/'

require 'snake/player'
require 'snake/food'
require 'snake/version'

# Simple monkeypatch to make MRuby's rand support Ranges.
# Use by include RandomExtension in the class/module you need
module RandomExtension
  # @param max [Numeric, Range]
  # @return [Integer, Float]
  def rand(max = 0)
    if max.is_a? Range
      super(max.max - max.min) + max.min
    else
      super(max)
    end
  end
end

# The main game window
class SnakeWindow < Gosu::Window
  include RandomExtension

  WINDOW_WIDTH  = 800
  WINDOW_HEIGHT = 608
  TILE_SIZE     = 16
  MAP_SPRITES   = { wall:  Gosu::Image.new('assets/wall.png'),
                    floor: Gosu::Image.new('assets/floor.png') }

  def initialize
    super(WINDOW_WIDTH, WINDOW_HEIGHT)
    self.caption = 'Snake-RB'

    @player = Player.new
    @food = Food.new
    @font = Gosu::Font.new(20)

    @eat_sound = Gosu::Sample.new('assets/sounds/eat.wav')

    @map = setup_map

    @score = 0

    puts "Snake v#{VERSION}"
  end

  # TODO: For the sake of my learning, I need to revisit this method to
  #       properly understand it and make it clear if I can. I did not use an
  #       LLM or anything of that sort, I actually wrote this myself based on
  #       some old code for another tile-based game of mine, but I'm still not
  #       clear on this code.
  def setup_map
    rows_length    = WINDOW_HEIGHT / TILE_SIZE
    columns_length = WINDOW_WIDTH / TILE_SIZE

    # Generate a map based on the window and tile size
    # TODO: Investigate if there's a better manner of creating a 2D array in Ruby
    gen_map = Array.new(rows_length) { Array.new(columns_length) }

    gen_map.each_with_index do |row, y|
      # If it is the first or last row, it should all be a wall
      if y.zero? || y == rows_length - 1
        row.map! { :wall }
      else
        row.each_with_index do |col, x|
          # If it is the first or last column in the row, it should be a wall
          if x.zero? || x == columns_length - 1
            row[x] = :wall
          else
            row[x] = :floor
          end
        end
      end
    end
  end

  # Returns the tile at the specified x and y coordinates.
  # @param x [Integer] The x position.
  # @param y [Integer] The y position.
  def tile_at(x, y)
    t_x = ((x / TILE_SIZE) % TILE_SIZE).floor
    t_y = ((y / TILE_SIZE) % TILE_SIZE).floor
    row = @map[t_y]
    row[t_x].to_i if row
  end

  def button_down(id)
    super

    @player.button_down(id)
  end

  def update
    update_dt

    @player.update(@dt)

    @score = 0 if @player.dead
    collision_snake_food
  end

  def collision_snake_food
    return unless @player.head.x == @food.x && @player.head.y == @food.y

    @score += 1
    @eat_sound.play

    @player.grow

    # Incredibly stupid way of making sure the randomized position of the new
    # fruit isn't on a wall (i.e. On all the tiles of the first and last rows and columns)
    srand
    @food.x = rand(1..49) * TILE_SIZE
    @food.y = rand(1..37) * TILE_SIZE
  end

  # Update the delta time variable, must be called on Gosu::Window#update
  def update_dt
    @dt ||= 0.0
    @last_ms ||= 0.0

    current_time = Gosu.milliseconds / 1000.0
    @dt = [current_time - @last_ms, 0.25].min
    @last_ms = current_time
  end

  def draw
    draw_map

    @player.draw
    @food.draw

    @font.draw_text("SCORE: #{@score}", 32, 32, 0)
  end

  def draw_map
    @map.each_with_index do |row, y|
      row.each_with_index do |tile_type, x|
        MAP_SPRITES[tile_type].draw(x * TILE_SIZE, y * TILE_SIZE)
      end
    end
  end
end

SnakeWindow.new.show
