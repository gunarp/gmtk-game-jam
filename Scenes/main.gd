extends Node

var current_scene: Node

@onready var level_select_scene = preload("res://Scenes/UI/Menus/level_select.tscn")
@onready var main_menu_scene = preload("res://Scenes/UI/Menus/main_menu.tscn")

@onready var levels = preload("res://Resources/level_collection.tres")

# Called when the node enters the scene tree for the first time.
func _ready():
  DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
  Engine.max_fps = 60
  # Engine.physics_ticks_per_second = 120;
  change_to_main_menu()

func change_scene(new_parent: Node, new_child: Node):
  if current_scene:
    current_scene.queue_free()
  new_parent.add_child(new_child)
  current_scene = new_child

func change_to_level(new_level: LevelResource, level_index: int):

  # queue up logic for next level

  if level_index >= levels.level_array.size():
    change_to_level_selection()
    return

  var level_scene: PackedScene = new_level.level_scene
  var level_to_load: BaseLevel = level_scene.instantiate()

  change_scene($LevelHolder, level_to_load)

  print("changed to level: ", level_index)

  levels.next_level_index = level_index + 1
  var nlCallable

  if levels.next_level_index < levels.level_array.size():
    nlCallable = change_to_level.bind(levels.level_array[levels.next_level_index], levels.next_level_index)
  else:
    nlCallable = change_to_level.bind(null, levels.next_level_index)
  level_to_load.level_ended.connect(nlCallable)


func change_to_menu(new_menu_scene: Node):
  change_scene($MenuHolder, new_menu_scene)


func change_to_level_selection():
  var scene = level_select_scene.instantiate()
  change_to_menu(scene)
  scene.level_selected.connect(change_to_level)
  scene.add_all_levels(levels)


func change_to_main_menu():
  var menu = main_menu_scene.instantiate()
  change_to_menu(menu)
  menu.play_pressed.connect(change_to_level.bind(levels.get_current_level(), 0))
  menu.level_select_pressed.connect(change_to_level_selection)
