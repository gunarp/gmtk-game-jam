extends Actor
class_name Player

@export var coyote_time_frames = 6;
@export var jump_time_frames = 6;


#Taken from Kids Can Code - https://kidscancode.org/godot_recipes/4.x/2d/platform_character/index.html

@export_range(0.0, 1.0) var friction = 0.1
@export_range(0.0, 1.0) var acceleration = 0.25


var health = 3

var jumping = true

# Class velocity
var calculated_velocity: Vector2 = Vector2.ZERO
var move_cooldown: Vector2 = Vector2.ZERO
var is_dash_active: bool = false
var can_dash: bool = true

#Coyote code based on KIDS CAN CODE
#https://kidscancode.org/godot_recipes/4.x/2d/coyote_time/index.html

var coyote = false # Track whether we're in coyote time or not

func _ready():
  super ()
  %CoyoteTimer.wait_time = coyote_time_frames / 60.
  %JumpBufferTimer.wait_time = jump_time_frames / 60.


func handle_animation(_delta):
  if is_on_floor():
    if velocity.x > 5:
      $AnimatedSprite2D.play("walk")
      $AnimatedSprite2D.flip_h = false
    elif velocity.x < -5:
      $AnimatedSprite2D.play("walk")
      $AnimatedSprite2D.flip_h = true
    else:
      $AnimatedSprite2D.play("default")
  else:
    if velocity.y < 0:
      $AnimatedSprite2D.play("jump")
    else:
      $AnimatedSprite2D.play("fall")


func handle_gravity(delta):
  if velocity.y > 0:
    delta *= 1.5
  if not is_dash_active and not is_on_floor():
    calculated_velocity.y += gravity * delta
  pass


func handle_physics(delta):
  # TODO: think about a way to funnel inputs into here outside of a regular loop
  if is_on_floor():
    can_dash = true
    jumping = false
  # Handle Jump.

  if not is_dash_active:
    handle_jump()
    handle_dash()
    var direction = Input.get_axis("move_left", "move_right")
    if move_cooldown.x <= 0:
      if direction:
        calculated_velocity.x = lerp(calculated_velocity.x, direction * speed, acceleration)
      else:
        calculated_velocity.x = lerp(calculated_velocity.x, 0.0, friction)

  # Do all calculations on the tracked calculated_velocity

  # Get the input direction and handle the movement/deceleration.

  velocity = calculated_velocity
  move_and_slide()
  #Handle all the collisions that have happened
  handle_cols()

  # store velocity for next frame's calculations
  calculated_velocity = velocity

  move_cooldown.x = move_toward(move_cooldown.x, 0, delta)
  move_cooldown.y = move_toward(move_cooldown.y, 0, delta)


func load_state(_state: PackedFloat32Array):
  calculated_velocity.x = _state[2]
  calculated_velocity.y = _state[3]
  super (_state)


func handle_jump():
  if Input.is_action_just_pressed("jump"):
    %JumpBufferTimer.start()
  if Input.is_action_just_released("jump") and calculated_velocity.y < 0:
    calculated_velocity.y *= 0.25
  if (not %JumpBufferTimer.is_stopped()) and (is_on_floor() or coyote):
    calculated_velocity.y = jump_vel
    %JumpBufferTimer.stop()
    jumping = true
    if coyote:
      coyote = false


func handle_dash():
  if Input.is_action_just_pressed("dash"):
    if not can_dash:
      print("couldn't dash")
      return
    if is_dash_active:
      print("already dashing")
      return

    var input_vect = Vector2(
      Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
      Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
    )

    var default_dash_direction = Vector2(1, 0) if not $AnimatedSprite2D.flip_h else Vector2(-1, 0)
    var dash_direction = default_dash_direction if input_vect == Vector2.ZERO else input_vect
    # print("dash requested, direction: ", dash_direction)
    # var dash_dir = vector2()

    var dash_multiplier = Vector2.ONE

    if dash_direction.x > 0:
      dash_multiplier.x = Constants.Dash_right_scale;
    elif dash_direction.x < 0:
      dash_multiplier.x = Constants.Dash_left_scale;

    if dash_direction.y < 0:
      dash_multiplier.y = Constants.Dash_up_scale;
    elif dash_direction.y > 0:
      dash_multiplier.y = Constants.Dash_down_scale;

    # print("dashing in direction of: ", dash_direction)
    calculated_velocity = dash_direction * Constants.Dash_Strength * dash_multiplier * 60
    # print("dashed, old velocity: ", velocity, " dash velocity:", calculated_velocity)

    move_cooldown = Vector2(0.5, 1) * Constants.Dash_input_cooldown
    is_dash_active = true
    can_dash = false
    $GPUParticles2D.emitting = true
    # asynchronously wait on timer to complete
    print("dash_start")
    await get_tree().create_timer(Constants.Dash_Strength * Constants.Dash_input_cooldown).timeout
    print("dash_end")
    is_dash_active = false
    $GPUParticles2D.emitting = false


func handle_cols():
  super ()

  if !is_on_floor() and last_floor and not jumping:
    coyote = true
    %CoyoteTimer.start()


func take_hit(hitter):
  velocity.x = global_position.direction_to(hitter.global_position).x * jump_vel * 3
  if is_on_floor():
    velocity.y = jump_vel * .5
  $AnimatedSprite2D.play("hurt")
  health -= 1
  # player_lost_health.emit(health)
  # if health <= 0:
  #   player_lost_all_health.emit()


func set_up_camera_limit(rect: Rect2i):
  print(rect)
  rect = rect.abs()
  # camera.limit_left = rect.position.x
  # camera.limit_top = rect.position.y
  # camera.limit_right = rect.end.x
  # camera.limit_bottom = rect.end.y


func _on_coyote_timer_timeout():
  coyote = false
  pass # Replace with function body.


func react_to_hitting(_hitbody):
  # Have the player jump
  velocity.y = jump_vel
  jumping = true
