require 'dxopal'
include DXOpal


class Enemy
  attr_reader :x, :y, :sprite

  def initialize(number)
    @number = number

    reset

    @speed  = choice_speed(@number)
    @sprite = create_sprite
  end

  def reset
    set_new_positions
    set_new_size
  end

  def set_new_positions
    @x = choice_new_x_position
    @y = choice_new_y_position
  end

  def set_new_size
    @width =  ENEMY_BODY_WIDTH
    @height = ENEMY_BODY_HEIGHT
  end

  def choice_new_x_position
    range = Range.new(-ENEMY_BODY_WIDTH, DISPLAY_WIDTH)
    rand(range)
  end

  def choice_new_y_position
    0 - rand(ENEMY_BODY_HEIGHT..DISPLAY_HEIGHT)
  end

  # たまに速いのが混じってる
  def choice_speed(number)
    number % 10 == 0 ? DEFAULT_ENEMY_SPEED * 3 : DEFAULT_ENEMY_SPEED
  end

  def create_sprite
    Sprite.new(@x, @y, Image.new(@width, @height, C_RED))
  end

  def move
    @y += @speed

    @sprite.x = x
    @sprite.y = y
  end

  def frame_out?
    @y > DISPLAY_HEIGHT
  end
end

class Player
  attr_reader :x, :y, :sprite

  def initialize
    set_default_position
    set_speed
    @sprite = create_sprite
  end

  def set_default_position
    @x = PLAYER_MOVE_WIDTH / 2
    @y = PLAYER_MOVE_HEIGHT - PLAYER_BODY_HEIGHT
  end

  def create_sprite
    Sprite.new(@x, @y, Image.new(PLAYER_BODY_WIDTH, PLAYER_BODY_HEIGHT, C_WHITE))
  end

  def set_speed
    @speed = DEFAULT_PLAYER_SPEED
    @slow_speed = DEFAULT_PLAYER_SLOW_SPEED
  end

  def move
    @x += position_diff(Input.x)
    @y += position_diff(Input.y)

    @x = @x.clamp(0, PLAYER_MOVE_WIDTH)
    @y = @y.clamp(0, PLAYER_MOVE_HEIGHT)

    @sprite.x = @x
    @sprite.y = @y
  end

  def position_diff(input_value)
    return 0 if input_value.to_i == 0

    if with_slow_move?
      input_value * @slow_speed
    else
      input_value * @speed
    end
  end

  def with_slow_move?
    Input.key_down?(K_SPACE)
  end
end

# 1レベル上がるごとに10体追加
def current_enemy_count
  val = START_ENEMY_COUNT + level * 10
  val.clamp(START_ENEMY_COUNT, MAX_ENEMY_COUNT)
end

def view_gameover_message
  font_size = 64
  font = Font.new(font_size)
  x = (DISPLAY_WIDTH  - font_size * 6) / 2
  y = (DISPLAY_HEIGHT - font_size) / 2
  Window.draw_font(x, y, "GAME OVER", font, color: C_YELLOW, z: 1)
end

def view_score
  font_size = 12
  font = Font.new(font_size)
  x = font_size
  y = font_size
  message = "SCORE: " + level.to_s
  Window.draw_font(x, y, message, font, color: C_WHITE)
end

def level
  (@score / 100).ceil
end

def gameover
  @flag = FLAG_GAMEOVER
  view_gameover_message
end

# config
DEFAULT_PLAYER_SPEED = 3
DEFAULT_PLAYER_SLOW_SPEED = 1
DEFAULT_ENEMY_SPEED  = 1

PLAYER_BODY_WIDTH  = 3
PLAYER_BODY_HEIGHT = 3

DISPLAY_WIDTH  = 640
DISPLAY_HEIGHT = 480

ENEMY_BODY_WIDTH  = 15
ENEMY_BODY_HEIGHT = 15
START_ENEMY_COUNT = 100
MAX_ENEMY_COUNT   = 2000

PLAYER_MOVE_WIDTH  = DISPLAY_WIDTH  - PLAYER_BODY_WIDTH
PLAYER_MOVE_HEIGHT = DISPLAY_HEIGHT - PLAYER_BODY_HEIGHT

FLAG_ON_PLAY  = 0
FLAG_GAMEOVER = 1


# setup
@flag  = FLAG_ON_PLAY
@score = 0

player  = Player.new
enemies = MAX_ENEMY_COUNT.times.map { |i| Enemy.new(i) }


# main loop
Window.width  = DISPLAY_WIDTH
Window.height = DISPLAY_HEIGHT

Window.load_resources do
  Window.bgcolor = C_BLACK

  Window.loop do
    if @flag == FLAG_ON_PLAY
      @score += 1
      player.move
    end

    player_sprite = player.sprite
    player_sprite.draw

    # enemy
    enemy_limt = current_enemy_count
    enemies.each_with_index do |enemy, i|
      next if i >= enemy_limt

      if @flag == FLAG_ON_PLAY
        enemy.move

        if enemy.frame_out?
          enemy.reset
        end
      end

      enemy_sprite = enemy.sprite
      enemy_sprite.draw

      # GAMEOVER
      if player_sprite === enemy_sprite
        gameover
      end
    end

    view_score
  end
end
