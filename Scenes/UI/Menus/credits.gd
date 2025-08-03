extends Control

@export var scroll_duration := 30.0  # pixels per second
@onready var label := $CreditsTextLabel
@onready var fade := $Fade
var tween 

func _ready():
  #await get_tree().process_frame
  label.size = label.get_combined_minimum_size()
  
  var start_x = (size.x - label.size.x) / 2
  var start_y = size.y
  var end_y = -label.size.y
  fade.modulate.a = 1.0 # fully opaque
  
  label.position = Vector2(start_x, start_y)
  tween = create_tween()
 #tween.tween_property(label, "position:y", -label.size.y, 30.0)
  tween.tween_property($Fade, "modulate:a", 0.0, 2.0) #fade out over 2 seconds
  tween.parallel().tween_property(label, "position:y", end_y, scroll_duration)
  
  tween.tween_callback(func():
    var fade_out = create_tween()
    fade_out.tween_property(fade, "modulate:a", 1.0, 2.0)
    fade_out.tween_callback(func():
      get_tree().change_scene_to_file("res://Scenes/UI/Menus/main_menu.tscn")))
