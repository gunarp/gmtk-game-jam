extends Node2D
class_name Stopwatch

var time = 0.0
var stopped = false

func _process(delta):
  if stopped:
    return
    time += delta
    
func reset():
  time = 0.0
  
