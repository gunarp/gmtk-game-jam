extends Area2D

func _on_body_entered(body):
  print("Entered:", body.name)
  if body.is_in_group("player"):
    print("Level Complete!")
    queue_free()
