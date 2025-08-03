extends Control

class_name TimelineMenuItem

var frame_number_display: int
var frame_number_real: int

const item_scene: PackedScene = preload("res://Scenes/UI/Menus/timeline_menu_item.tscn")

func _init(display_number: int = 0, real_number: int = 0):
  frame_number_display = display_number
  frame_number_real = real_number


static func create_item(display_number: int = 0, real_number: int = 0):
  var new_item = item_scene.instantiate()
  new_item.frame_number_display = display_number
  new_item.frame_number_real = real_number
  return new_item


func _ready():
  $Label.text = str(frame_number_display)


func apply_material(mat: ShaderMaterial):
  $TextureRect.material = mat


func set_texture(_path: String):
  # TODO figure this out
  pass