class Segment
  attr_accessor :x, :y

  # Created in a constant so that a new sprite isn't instanciated each
  # time the snake grows/resets
  SPRITES = [Gosu::Image.new('assets/head/1.png'),
             Gosu::Image.new('assets/head/2.png'),
             Gosu::Image.new('assets/head/3.png'),
             Gosu::Image.new('assets/head/4.png'),
             Gosu::Image.new('assets/body.png')]

  def initialize(x, y)
    @x, @y = x, y
  end
end
