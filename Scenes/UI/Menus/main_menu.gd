extends Control

signal play_pressed
signal level_select_pressed

func _on_play_pressed():
  play_pressed.emit()

func _on_level_select_pressed():
  level_select_pressed.emit()

func _on_options_pressed() -> void:
  pass # Replace with function body.
