extends     Spatial
class_name  editor


onready var map : Spatial  = get_parent()
onready var cam : Camera   = $"../%Cam"






func _ready() -> void:
	pass






func _input(event: InputEvent) -> void:
	if event.is_action_pressed("key1"):
		cam.hex.queue_free()
		map.add_tile("flat", cam.hex_pos)

