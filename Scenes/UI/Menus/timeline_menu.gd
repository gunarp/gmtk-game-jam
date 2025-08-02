extends Control

@onready var frame_container: HBoxContainer = %FrameContainer
@onready var scroll_container: ScrollContainer = %ScrollContainer

@onready var prev_button: Button = %PreviousButton
@onready var next_button: Button = %NextButton

@onready var outline_mat: ShaderMaterial = ShaderMaterial.new()

signal unfreeze

var ignore_input = false
var targetScroll = 0

const padding: int = 90

var num_frames: int = 0
var max_scroll: int = 0
var min_scroll: int = 0

var has_been_set: bool = false

class EmptyMargin extends MarginContainer:
  func _init() -> void:
    # TODO: replace magic number
    add_theme_constant_override("margin_right", padding)


func _ready() -> void:
  outline_mat.shader = preload("res://Resources/2d_outline.gdshader")

  _set_selection()
  visibility_changed.connect(_on_visibility_changed)

  #EXTRACT
  # for child in scroll_container.get_children():
  #   child.queue_free()

  frame_container.add_child(EmptyMargin.new())

  # Set children of frame_container to be selectable frames... for now just use a placeholder asset
  var new_child = TextureRect.new()
  new_child.texture = load("res://Assets/UI/hud_heartFull.png")

  num_frames = 0
  for i in range(6):
    var copy = new_child.duplicate()
    frame_container.add_child(copy)
    num_frames += 1

  frame_container.add_child(EmptyMargin.new())

  max_scroll = (_get_space_between() * (num_frames - 1))
  #EXTRACT

  # move scroll position to end, after ScrollContainer is ready
  set_scroll_at_end.call_deferred()


func set_scroll_at_end():
  # TODO: make this scroll to the center of the last object in the list
  targetScroll = max_scroll
  print("scrolling to ", max_scroll)
  scroll_container.scroll_horizontal = max_scroll


func _on_visibility_changed():
  if is_visible_in_tree():
    ignore_input = true


func display_frames_on_pause(timeline: Array[Dictionary], current_timeline_pos: int, num_timelines_looped: int, max_frames: int) -> void:
  print("stopped on frame: ", num_timelines_looped * max_frames + current_timeline_pos)
  print(timeline[current_timeline_pos])
  # trying to dynamically generate a texture - failing !
  # var test_texture = load("res://Assets/Player/walk_left_7.png")
  # var temp = TextureRect.new()
  # temp.texture = test_texture
  # temp.visible = true
  # frame_container.add_child(temp)
  # for item in frame_container.get_children():
  #   print(item.name)
  # populat ethe contents of the frame_container with the timeline


func _process(_delta: float) -> void:
  # Do a lil debouncing and ignore the first input
  #  (which is probably the input) hat opened the menu to begin with
  if ignore_input:
    ignore_input = false
    return

  if Input.is_action_just_pressed("freeze"):
    print("current scroll value: ", scroll_container.scroll_horizontal)
    var dest_frame = 10
    unfreeze.emit(dest_frame)

  if Input.is_action_just_pressed("scrub_back"):
    _on_previous_button_pressed()

  if Input.is_action_just_pressed("scrub_forward"):
    _on_next_button_pressed()


func _set_selection():
  await get_tree().create_timer(0.01).timeout
  _select_deselect_highlight()


func _on_previous_button_pressed() -> void:
  var scrollValue = max(targetScroll - _get_space_between(), min_scroll)

  print("previous: ", scrollValue)

  await _tween_scroll(scrollValue)

  _select_deselect_highlight()


func _on_next_button_pressed() -> void:
  var scrollValue = min(targetScroll + _get_space_between(), max_scroll)

  print("next: ", scrollValue)

  await _tween_scroll(scrollValue)

  _select_deselect_highlight()


func _get_space_between():
  var distanceSize = frame_container.get_theme_constant("separation")
  # kind of boldly assumes there's only one object size... could probably
  # fill this in with another property during onready
  var objectSize = frame_container.get_children()[1].size.x

  return distanceSize + objectSize


func _tween_scroll(scrollValue):
  targetScroll = scrollValue

  var tween = get_tree().create_tween()
  tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
  tween.tween_property(scroll_container, "scroll_horizontal", scrollValue, 0.15)
  await tween.finished


func _select_deselect_highlight():
  var selectedNode = get_selected_value()

  for object in frame_container.get_children():
    if object is not TextureRect:
      continue

    var tex = object as TextureRect

    if object == selectedNode:
      tex.material = outline_mat
    else:
      tex.material = null


func get_selected_value():
  var selectedPosition = %SelectionMarker.global_position

  for object in frame_container.get_children():
    if object.get_global_rect().has_point(selectedPosition):
      print("    selected_node: ", object.name)
      return object
