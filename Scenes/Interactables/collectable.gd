extends Interactable
class_name Collectable

func _ready():
  var call = Callable(self, "_on_body_entered")
  if not is_connected("body_entered", call):
    connect("body_entered", call)
  
func _on_body_entered(body: Node) -> void:
  print("body entered:", body.name)
  if body.is_in_group("player"):
    print("LEVEL COMPLETE")
    queue_free()
