class Food
  attr_accessor :x, :y

  def initialize(default_x = 128, default_y = 304)
    @x = default_x
    @y = default_y
    @sprite = Gosu::Image.new('assets/apple.png')
  end

  def draw
    @sprite.draw(@x, @y)
  end
end
