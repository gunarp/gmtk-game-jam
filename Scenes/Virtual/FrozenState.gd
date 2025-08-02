class_name FrozenState extends Node

# will contain either
# [pos.x, pos.y, vel.x, vel.y]
# or
# [position along predetermined path]
var frozenState: PackedFloat32Array

func _init(_state: PackedFloat32Array):
  frozenState = _state.duplicate()


func _to_string() -> String:
  return str(frozenState)
