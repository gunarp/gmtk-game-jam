extends Control

@onready var frame_container: HBoxContainer = %FrameContainer
@onready var scroll_container: ScrollContainer = %ScrollContainer

var ignore_input = false

signal unfreeze

var targetScroll = 0

func _ready() -> void:
  _set_selection()
  visibility_changed.connect(_on_visibility_changed)


func _on_visibility_changed():
  if is_visible_in_tree():
    ignore_input = true


func display_frames_on_pause(timeline: Array[Dictionary], current_timeline_pos: int, num_timelines_looped: int, max_frames: int) -> void:
  print("stopped on frame: ", num_timelines_looped * max_frames + current_timeline_pos)
  # populat ethe contents of the frame_container with the timeline


func _process(_delta: float) -> void:
  # Do a lil debouncing and ignore the first input (which is probably the input)
  # that opened the menu to begin with
  if ignore_input:
    ignore_input = false
    return

  if Input.is_action_just_pressed("freeze"):
    unfreeze.emit()


func _set_selection():
  await get_tree().create_timer(0.01).timeout
  _select_deselect_highlight()


func _on_previous_button_pressed() -> void:
  print("previous")
  var scrollValue = targetScroll - _get_space_between()

  if scrollValue < 0: scrollValue = _get_space_between() * 2

  await _tween_scroll(scrollValue)

  _select_deselect_highlight()


func _on_next_button_pressed() -> void:
  print("next")
  var scrollValue = targetScroll + _get_space_between()

  if scrollValue > _get_space_between() * 2: scrollValue = 0

  await _tween_scroll(scrollValue)

  _select_deselect_highlight()


func _get_space_between():
  var distanceSize = frame_container.get_theme_constant("separation")
  var objectSize = frame_container.get_children()[1].size.x

  return distanceSize + objectSize


func _tween_scroll(scrollValue):
  targetScroll = scrollValue

  var tween = get_tree().create_tween()
  tween.tween_property(scroll_container, "scroll_horizontal", scrollValue, 0.25)
  await tween.finished


func _select_deselect_highlight():
  var selectedNode = get_selected_value()

  for object in frame_container.get_children():
    if object is not TextureRect: continue

    if object == selectedNode: object.modulate = Color(1, 1, 1)
    else: object.modulate = Color(0, 0, 0)


func get_selected_value():
  var selectedPosition = %SelectionMarker.global_position

  for object in frame_container.get_children():
    if object.get_global_rect().has_point(selectedPosition):
      return object
