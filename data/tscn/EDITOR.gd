extends     Spatial
class_name  editor


export var PARTICLES : PackedScene
export var SOUNDS    : PackedScene

var sounds : Spatial

onready var map  : Spatial  = get_parent()
onready var cam  : Camera   = $"../%Cam"

var def_emit_str := .8


## Holders:
var s_tile_place  : AudioStreamPlayer






func _ready() -> void:
	sounds  = SOUNDS.instance()
	add_child(sounds)
	s_tile_place  = sounds.get_node("tile_place")





func _input(event: InputEvent) -> void:
	var type      := "water"

	if event.is_action_pressed("key1"):
		var cycle_sum : float = (map.LightCycle.sun_p + map.LightCycle.moon_p) * .5


		if cam.hex:
			var corr      : float    ## Y-axis correction when placing on water
			var particles : CPUParticles

			particles           = PARTICLES.instance()
			particles.position  = cam.hex_pos - Vector3(0, 2, 0)
			particles.material_override.emission_energy = def_emit_str * (2 -cycle_sum)
			particles.emitting  = true

			var keys  = map.tiles_def.keys()

			while type == "water":
				type  = keys[randi() % keys.size()-1]

			add_child(particles)
			corr  = .1 if cam.hex.position.y < 0.0 else 0.0

			s_tile_place.pitch_scale  = rand_range(1.6, 4.6)
			s_tile_place.playing  = true

			cam.hex.queue_free()
			map.add_tile(type, corr)

	elif event.is_action_pressed("map_regenerate"):
		get_tree().call_group("hex", "queue_free")
		map.map_gen()

