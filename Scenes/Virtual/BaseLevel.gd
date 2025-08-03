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

# Indexed by frame
var timeline: Array[Dictionary]
var num_timelines_looped: int = 0
var current_timeline_pos: int = 0
var skipped_frames: int = 0
const NUM_SKIP_FRAMES: int = 3
const MAX_TIMELIINE_LENGTH: int = 300

var is_paused: bool = false

signal level_ended

# Called when the node enters the scene tree for the first time.
func _ready():
  # prefill the timeline
  timeline.resize(MAX_TIMELIINE_LENGTH)

  var cell_size: Vector2i = $ForegroundLayer.tile_set.tile_size
  boundry_rect = Rect2i($ForegroundLayer.get_used_rect()).abs()
#	boundry_rect = boundry_rect.grow_side(SIDE_TOP, 500)
  boundry_rect.size *= cell_size
  boundry_rect.position *= cell_size

  # $Player.set_up_camera_limit(boundry_rect)
  $TimelineMenu.connect("unfreeze", on_unfreeze)
  $TimelineMenu.connect("project_vector", on_project_vector)

  after_ready.call_deferred()


func _process(delta):
  time_taken += delta
  ui.update_time(time_taken)

  handle_freeze()
  # Save all freezable game object states in timeline
  # TODO: determine if every frame is actually necessary to save

  if (skipped_frames == NUM_SKIP_FRAMES):
    for child in get_children():
      if child.has_method("get_state"):
        timeline[current_timeline_pos][child.get_instance_id()] = FrozenState.new(child.get_state())
        # print("state stored, id:", child.get_instance_id(), " state: ", timeline[current_timeline_pos][child.get_instance_id()])

    current_timeline_pos = current_timeline_pos + 1
    if current_timeline_pos == MAX_TIMELIINE_LENGTH:
      current_timeline_pos = 0
      num_timelines_looped += 1
  else:
    skipped_frames += 1


func after_ready():
  #As the player is added to the tilemap, it needs to wait a frame for
  #everything to get ready!
  # $Player.set_up_camera_limit(boundry_rect)
  starting_pos = $Player.position


# Toggles pause state and applies it to subtree
func _toggle_pause_subtree():
  is_paused = not is_paused
  # print("toggling paused to: ", is_paused)
  if is_paused:
    $TimelineMenu.display_frames_on_pause(timeline, current_timeline_pos, num_timelines_looped, MAX_TIMELIINE_LENGTH)
  else:
    $Line2D.clear_points()
    $TimelineMenu.hide()
  get_tree().paused = is_paused


func handle_freeze():
  if Input.is_action_just_pressed("freeze"):
    if not is_paused:
      _toggle_pause_subtree()


func on_project_vector(proj: Vector2):
  # draw vector starting at player position
  $Line2D.clear_points()
  $Line2D.add_point($Player.global_position)
  $Line2D.add_point($Player.global_position + proj / 5)
  # $Line2D.global_rotation = 0


func on_unfreeze(unfreeze_frame, unfreeze_input, toggle_pause):
  if toggle_pause:
    _toggle_pause_subtree()
  unfreeze_at_frame(unfreeze_frame, unfreeze_input)


func unfreeze_at_frame(dest_frame: int, unfreeze_input):
  for child in get_children():
    if child.has_method("load_state"):
      # print("dest_frame: ", num_timelines_looped * MAX_TIMELIINE_LENGTH + dest_frame)
      var state: FrozenState = timeline[dest_frame][child.get_instance_id()]
      current_timeline_pos = dest_frame
      # print("loadingstate: ", state.frozenState)
      child.load_state(current_timeline_pos + (num_timelines_looped * MAX_TIMELIINE_LENGTH), state.frozenState, unfreeze_input)


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

  # remove_child($Player)
  # var player: Player = player_scene.instantiate()
  # add_child(player)
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
