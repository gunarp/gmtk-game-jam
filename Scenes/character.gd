extends Sprite2D

@export var speed = 1200
@export var jump_speed = -1800
@export var gravity = 4000

func _ready():
  $PlayerAnimation.play("idle_right")

func _physics_process(_delta):
  # velocity.y += gravity * delta #Gravity every frame

  # velocity.x = Input.get_axis("left", "right") * speed
  # move_and_slide()
  pass
