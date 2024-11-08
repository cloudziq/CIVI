extends     Spatial
class_name  editor


export var PARTICLES : PackedScene


onready var map : Spatial  = get_parent()
onready var cam : Camera   = $"../%Cam"


## Holders:
#var particles : Particles






#func _ready() -> void:
#	pass






func _input(event: InputEvent) -> void:
	var particles : CPUParticles

	if event.is_action_pressed("key1"):
		if cam.hex:
			particles           = PARTICLES.instance()
			particles.position  = cam.hex_pos
			particles.emitting  = true
			add_child(particles)
			cam.hex.queue_free()
			map.add_tile("flat", cam.hex_pos)
	elif event.is_action_pressed("map_regenerate"):
		get_tree().call_group("hex", "queue_free")
		map.map_gen()

