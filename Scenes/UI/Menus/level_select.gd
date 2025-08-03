extends Control

@onready var grid = %LevelGrid

@onready var level_selector_scene: PackedScene = preload("res://Scenes/UI/Parts/level_selector.tscn")

var level_index: int = 0

signal level_selected(level, level_id)

# Called when the node enters the scene tree for the first time.
func _ready():
  pass # Replace with function body.


func add_level(level: LevelResource):
  var selector := level_selector_scene.instantiate()
  grid.add_child(selector)
  selector.level_name = level.level_name
  var this_level_index = level_index
  var signal_emit_callable = emit_level_selected.bind(level, this_level_index)
  selector.button.pressed.connect(signal_emit_callable)
  level_index += 1


func add_all_levels(level_res: LevelCollectionResource):
  for level in level_res.level_array:
    add_level(level)


func emit_level_selected(level, level_id):
  print("selected level: ", level_id)
  level_selected.emit(level, level_id)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
  pass
