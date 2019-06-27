require 'dxopal'
include DXOpal


def enemy_new_position_x
  range = Range.new(-ENEMY_BODY_LENGTH, DISPLAY_WIDTH)
  rand(range)
end

def enemy_new_position_y
  0 - rand(ENEMY_BODY_HEIGHT..DISPLAY_HEIGHT)
end

def create_enemy
  Sprite.new(enemy_new_position_x, enemy_new_position_y, Image.new(ENEMY_BODY_LENGTH, ENEMY_BODY_HEIGHT, C_RED))
end

def enemy_width_range
  val = (level / 2).floor
  Range.new(val * -1, val)
end

def view_gameover_message
  font_size = 64
  font = Font.new(font_size)
  x = (DISPLAY_WIDTH  - font_size * 6) / 2
  y = (DISPLAY_HEIGHT - font_size) / 2
  Window.draw_font(x, y, "GAME OVER", font, color: C_YELLOW)
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

# 1レベル上がるごとに10体追加
def current_enemy_count
  val = START_ENEMY_COUNT + level * 10
  val.clamp(START_ENEMY_COUNT, MAX_ENEMY_COUNT)
end

def player_position_diff(input_value)
  return 0 if input_value.to_i == 0

  if Input.key_down?(K_SPACE)
    input_value * @player_slow_speed
  else
    input_value * @player_speed
  end
end

def gameover
  @flag = FLAG_GAMEOVER
  @player_speed = 0
  @player_slow_speed = 0
  @enemy_speed  = 0
  view_gameover_message
end

# たまに速いのが混じってる
def calc_enemy_speed(i)
  i % 10 == 0 ? @enemy_speed * 3 : @enemy_speed
end

# config
DEFAULT_PLAYER_SPEED = 3
DEFAULT_PLAYER_SLOW_SPEED = 1
DEFAULT_ENEMY_SPEED  = 1

BODY_LENGTH = 3
BODY_HEIGHT = 3

DISPLAY_WIDTH  = 640
DISPLAY_HEIGHT = 480

ENEMY_BODY_LENGTH = 15
ENEMY_BODY_HEIGHT = 15
START_ENEMY_COUNT = 100
MAX_ENEMY_COUNT   = 2000

PLAYER_WIDTH  = DISPLAY_WIDTH - BODY_LENGTH
PLAYER_HEIGHT = DISPLAY_HEIGHT - BODY_HEIGHT

FLAG_ON_PLAY  = 0
FLAG_GAMEOVER = 1


# setup
@player_speed = DEFAULT_PLAYER_SPEED
@player_slow_speed = DEFAULT_PLAYER_SLOW_SPEED
@enemy_speed  = DEFAULT_ENEMY_SPEED

@flag  = FLAG_ON_PLAY
@score = 0

player_x = PLAYER_WIDTH / 2
player_y = PLAYER_HEIGHT - BODY_HEIGHT

player = Sprite.new(player_x, player_y, Image.new(BODY_LENGTH, BODY_HEIGHT, C_WHITE))

enemies = MAX_ENEMY_COUNT.times.map { create_enemy }
enemy_speeds = MAX_ENEMY_COUNT.times.map { |i| calc_enemy_speed(i) }


# main loop
Window.load_resources do
  Window.bgcolor = C_BLACK

  Window.loop do
    if @flag == FLAG_ON_PLAY
      @score += 1
    end

    player_x += player_position_diff(Input.x)
    player_y += player_position_diff(Input.y)

    player_x = player_x.clamp(0, PLAYER_WIDTH)
    player_y = player_y.clamp(0, PLAYER_HEIGHT)

    player.x = player_x
    player.y = player_y
    player.draw

    # enemy
    enemy_limt = current_enemy_count
    enemies.each_with_index do |enemy, i|
      next if i >= enemy_limt

      if @flag == FLAG_ON_PLAY
        enemy.y += enemy_speeds[i]
        #enemy.x += rand(enemy_width_range)

        if enemy.y >= DISPLAY_HEIGHT
          enemy.x = enemy_new_position_x
          enemy.y = enemy_new_position_y
        end
      end

      enemy.draw

      # GAMEOVER
      if player === enemy
        gameover
      end
    end

    view_score
  end
end
