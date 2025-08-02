extends Node2D
class_name BaseLevel

@onready var boundry_rect: Rect2i
@onready var player_scene = preload("res://Scenes/Player/player.tscn")

var levelscore = 0
var time_taken = 0
var starting_pos: Vector2

var respawning: bool = false

var level_resource: LevelResource
@onready var ui := $LevelUI

var current_checkpoint: Checkpoint

signal level_ended

# Called when the node enters the scene tree for the first time.
func _ready():
  var cell_size: Vector2i = $ForegroundLayer.tile_set.tile_size
  boundry_rect = Rect2i($ForegroundLayer.get_used_rect()).abs()
#	boundry_rect = boundry_rect.grow_side(SIDE_TOP, 500)
  boundry_rect.size *= cell_size
  boundry_rect.position *= cell_size

  # $Player.set_up_camera_limit(boundry_rect)
  after_ready.call_deferred()


func _process(delta):
  time_taken += delta
  ui.update_time(time_taken)


func after_ready():
  #As the player is added to the tilemap, it needs to wait a frame for
  #everything to get ready!
  # $Player.set_up_camera_limit(boundry_rect)
  starting_pos = $Player.position


func on_player_touched(node: Interactable):
  if node is Exit:
    exit_level()
  elif node is Checkpoint:
    activate_checkpoint(node)
  elif node is Collectable:
    node.collect()
    update_score(100)
  elif node is DeathZone:
    kill_player()

#Methods called by interactables/enemies

func update_score(value):
  levelscore += value
  ui.update_score(levelscore)


func reset_score():
  levelscore = 0
  ui.update_score(levelscore)


func exit_level():
  print("ended")
  level_ended.emit()


func activate_checkpoint(node):
  if current_checkpoint:
    current_checkpoint.active = false
  current_checkpoint = node
  current_checkpoint.active = true


func kill_player():
  respawning = true
  respawn.call_deferred()


func respawn():
  if !respawning:
    # Minor optimization to only respawn once
    # This function might get invoked multiple times
    # if the player has multiple collisions with a death zone
    return

  remove_child($Player)
  var player: Player = player_scene.instantiate()
  add_child(player)
  $Player.position = starting_pos
  respawning = false

  # for collectable in get_tree().get_nodes_in_group("collectable"):
  #   collectable.collected = false
  # reset_score()


func _on_tile_map_child_entered_tree(node):
  # Handle the noeds that are instanced by the tile map.
  # Potential change - Have them added to the test level instead?
  if node.is_in_group("interactable"):
    node.player_touched.connect(on_player_touched.bind(node))
  if node.is_in_group("actor"):
    node = node as Actor
    node.hit_body.connect(_on_hit_body.bind(node))


func _on_hit_body(hitbody: Actor, hitter: Actor):
  hitbody.take_hit(hitter)
  hitter.react_to_hitting(hitbody)


func _on_player_lost_health(_new_health):
  ui.lose_health()
