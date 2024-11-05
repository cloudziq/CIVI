extends Spatial


var map_radius :=  40
var hex_radius :=  2
var noise      :=  OpenSimplexNoise.new()

var map_data       := {}

var tiles_def := {
	"flat01":     preload("res://data/objects/map_tiles/flat01.tscn"),
	"hill01":     preload("res://data/objects/map_tiles/hill01.tscn"),
	"mountain01": preload("res://data/objects/map_tiles/mountain01.tscn"),
	"water01":    preload("res://data/objects/map_tiles/water01.tscn")
}






func _ready() -> void:
	randomize()
	var LightCycle    := DayNightLightCycle.new()

	noise.seed         = randi()
	noise.octaves      = int(rand_range(2, 3))
	noise.period       = rand_range(6, 8)    *noise.octaves *map_radius *.025
	noise.persistence  = rand_range(6, 10)    *noise.period  *map_radius *12
	noise.lacunarity   = rand_range(.4, 2.6) +noise.octaves *map_radius *.4

	map_gen()
#	yield(get_tree().create_timer(.1), "timeout")
	add_child(LightCycle)







func map_gen() -> void:
#	var data : Dictionary
	var instance  : StaticBody
	var transform : Transform

	for q in range(-map_radius, map_radius + 1):
		for r in range(-map_radius, map_radius + 1):
			var s := -q -r

			if abs(s) <= map_radius:
				var noise_value = noise.get_noise_2d(float(q) *.042, float(r) *.042)

				transform        = Transform()
				transform.origin = hex_to_world(q, r)

				if noise_value >.12:
					var random_rotation = deg2rad(randi() %6 *60)
					transform.basis = Basis(Vector3(0, 1, 0), random_rotation)


				if noise_value >.52 and randf() >.66:
					instance  = tiles_def["mountain01"].instance()

				elif noise_value >.3 and randf() <.22:
					instance  = tiles_def["hill01"].instance()

				elif noise_value >.12:
					instance  = tiles_def["flat01"].instance()

				else:
					instance  = tiles_def["water01"].instance()
					transform.origin.y -=  .1
#				hex_map_data[Vector2(q, r)] = data

				instance.transform = transform
				add_child(instance)






func add_tile(type:String, pos:Vector3) -> void:
	var instance        :  StaticBody
	var transform       := Transform()
	var random_rotation  = deg2rad(randi() %6 *60)

	match type:
		"flat": instance = tiles_def["flat01"].instance()
		"hill": instance = tiles_def["hill01"].instance()

	transform.basis      = Basis(Vector3(0, 1, 0), random_rotation)
	transform.origin     = pos
	instance.transform   = transform
	add_child(instance)






func hex_to_world(xx: int, yy: int) -> Vector3:
	var x = hex_radius * 3 * .5 * yy
	var z = hex_radius * sqrt(3) * (xx + yy * .5)
	return Vector3(x, 0, z)
