require 'snake/segment'

class Player
  attr_reader :x, :y, :dead

  MOVE_TIME_MS = 90

  def initialize
    @positions = [Segment.new(32, 304)]

    @direction = :stop
    @growing = false
    @dead = false

    @sprite = Gosu::Image.new('assets/head/1.png')
  end

  def reset
    @positions = [Segment.new(48, 304)]
    @direction = :stop
  end

  def grow
    @growing = true
  end

  def head
    @positions.last
  end

  def button_down(id)
    case id
    when Gosu::KB_LEFT
      @direction = :left unless @direction == :right
    when Gosu::KB_RIGHT
      @direction = :right unless @direction == :left
    when Gosu::KB_UP
      @direction = :up unless @direction == :down
    when Gosu::KB_DOWN
      @direction = :down unless @direction == :up
    end
  end

  def update(dt)
    update_movement_timer(dt)
    check_collision
  end

  def check_collision
    if @positions.last.x + SnakeWindow::TILE_SIZE >= SnakeWindow::WINDOW_WIDTH ||
       @positions.last.x <= 0 ||
       @positions.last.y + SnakeWindow::TILE_SIZE >= SnakeWindow::WINDOW_HEIGHT ||
       @positions.last.y <= 0
    then
      @dead = true
      reset
    end
  end

  def update_movement_timer(dt)
    @move_timer ||= 0.0
    @move_timer += dt

    return unless @move_timer >= MOVE_TIME_MS / 1000.0

    @move_timer = 0.0
    move
  end

  def move
    return if @direction == :stop

    # TODO: ???
    @positions.shift unless @growing || @positions.length == 1

    case @direction
    when :left
      @positions.push(Segment.new(@positions.last.x -= SnakeWindow::TILE_SIZE, @positions.last.y))
    when :right
      @positions.push(Segment.new(@positions.last.x += SnakeWindow::TILE_SIZE, @positions.last.y))
    when :up
      @positions.push(Segment.new(@positions.last.x, @positions.last.y -= SnakeWindow::TILE_SIZE)) 
    when :down
      @positions.push(Segment.new(@positions.last.x, @positions.last.y += SnakeWindow::TILE_SIZE))
    end
    @growing = false
  end

  def draw
    @positions.each_with_index do |pos, idx|
      if idx == @positions.length - 1
        case @direction
        when :left
          Segment::SPRITES[2].draw(pos.x, pos.y, 1)
        when :right, :stop
          Segment::SPRITES[0].draw(pos.x, pos.y, 1)
        when :up
          Segment::SPRITES[3].draw(pos.x, pos.y, 1)
        when :down
          Segment::SPRITES[1].draw(pos.x, pos.y, 1)
        end
      else
        Segment::SPRITES[4].draw(pos.x, pos.y)
      end
    end
  end
end
