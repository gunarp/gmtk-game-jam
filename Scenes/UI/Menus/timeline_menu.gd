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

class EmptyMargin extends MarginContainer:
  func _init() -> void:
    # TODO: replace magic number
    add_theme_constant_override("margin_right", padding)


func _ready() -> void:
  outline_mat.shader = preload("res://Resources/2d_outline.gdshader")
  visibility_changed.connect(_on_visibility_changed)

  # move scroll position to end, after ScrollContainer is ready
  # set_scroll_at_end.call_deferred()


func set_scroll_at_end():
  # TODO: make this scroll to the center of the last object in the list
  targetScroll = max_scroll
  show()
  await _tween_scroll(targetScroll)
  _select_deselect_highlight()


func _on_visibility_changed():
  if is_visible_in_tree():
    ignore_input = true


func generate_frames_for_container(timeline: Array[Dictionary], current_timeline_pos: int, max_frames: int) -> void:
  if frame_container != null:
    for child in frame_container.get_children():
      if child != null:
        child.queue_free()

  frame_container.add_child(EmptyMargin.new())

  # naieve approach - add all frames
  # the end of the array is current_timeline_pos and loops around
  # to current_timeline_pos + 1, or the first spot where
  # the value of the timeline is null

  num_frames = 0

  # foolishly load in the array in reverse order
  for i in range(current_timeline_pos + 1, max_frames):
    if timeline[i].is_empty():
      break

    var display_number = -1 * (current_timeline_pos + (max_frames - i))
    var new_child = TimelineMenuItem.create_item(display_number, i)
    frame_container.add_child(new_child)
    num_frames += 1

  for i in range(0, current_timeline_pos + 1):
    frame_container.add_child(TimelineMenuItem.create_item(i - current_timeline_pos, i))
    num_frames += 1

  frame_container.add_child(EmptyMargin.new())
  max_scroll = (_get_space_between() * (num_frames - 1))


func display_frames_on_pause(timeline: Array[Dictionary], current_timeline_pos: int, num_timelines_looped: int, max_frames: int) -> void:
  print("stopped on frame: ", num_timelines_looped * max_frames + current_timeline_pos)
  print(timeline[current_timeline_pos])

  generate_frames_for_container(timeline, current_timeline_pos, max_frames)
  set_scroll_at_end()


func _process(_delta: float) -> void:
  # Do a lil debouncing and ignore the first input
  #  (which is probably the input) hat opened the menu to begin with
  if ignore_input:
    ignore_input = false
    return

  if Input.is_action_just_pressed("freeze"):
    # print("current scroll value: ", scroll_container.scroll_horizontal)
    # var dest_frame = 10
    var selection = get_selected_value()
    if selection is TimelineMenuItem:
      var s = selection as TimelineMenuItem
      # true = unfreeze after displaying frame
      unfreeze.emit(s.frame_number_real, true)

  if Input.is_action_pressed("scrub_back"):
    _on_previous_button_pressed()
    var selection = get_selected_value()
    if selection is TimelineMenuItem:
      var s = selection as TimelineMenuItem
      # false = only display frame, do NOT unfreeze
      unfreeze.emit(s.frame_number_real, false)

  if Input.is_action_pressed("scrub_forward"):
    _on_next_button_pressed()
    var selection = get_selected_value()
    if selection is TimelineMenuItem:
      var s = selection as TimelineMenuItem
      unfreeze.emit(s.frame_number_real, false)


func _set_selection():
  await get_tree().create_timer(0.01).timeout
  _select_deselect_highlight()


func _on_previous_button_pressed() -> void:
  var scrollValue = max(targetScroll - _get_space_between(), min_scroll)

  await _tween_scroll(scrollValue)

  _select_deselect_highlight()


func _on_next_button_pressed() -> void:
  var scrollValue = min(targetScroll + _get_space_between(), max_scroll)

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
    if object is not TimelineMenuItem:
      continue

    var item = object as TimelineMenuItem

    if object == selectedNode:
      item.apply_material(outline_mat)
    else:
      item.apply_material(null)


func get_selected_value():
  var selectedPosition = %SelectionMarker.global_position

  for object in frame_container.get_children():
    if object.get_global_rect().has_point(selectedPosition):
      return object
