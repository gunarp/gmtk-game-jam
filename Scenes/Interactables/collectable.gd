extends Interactable
class_name Collectable

func _ready():
    player_touched.connect(Callable(self, "collect"))

func collect():
    print("LEVEL COMPLETE")
    queue_free()
