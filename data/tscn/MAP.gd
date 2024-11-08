extends Spatial


onready var cam := $"%Cam"

var LightCycle : DayNightLightCycle
var map_radius := 40
var hex_radius := 2
var hex_height : float
var noise      :  OpenSimplexNoise

var map_data       := {}

var tiles_def := {
	"flat":     preload("res://data/objects/map_tiles/flat01.tscn"),
	"hill":     preload("res://data/objects/map_tiles/hill01.tscn"),
	"mountain": preload("res://data/objects/map_tiles/mountain01.tscn"),
	"water":    preload("res://data/objects/map_tiles/water01.tscn")
}






func _ready() -> void:
	randomize()
	LightCycle  = DayNightLightCycle.new()

	map_gen()
	add_child(LightCycle)







func map_gen() -> void:
#	var data : Dictionary
	var instance  :  StaticBody
	var transform :  Transform
	var scale     := map_radius * .01

	noise  = OpenSimplexNoise.new()
	noise.seed         = randi()
	noise.octaves      = int(rand_range(3, 4))
	noise.period       = rand_range(2.8, 4.2)
	noise.persistence  = rand_range(.6, 1)
	noise.lacunarity   = rand_range(.6, 4)


	for q in range(-map_radius, map_radius + 1):
		for r in range(-map_radius, map_radius + 1):
			var s := -q -r

			if abs(s) <= map_radius:
				var noise_value = noise.get_noise_2d(float(q) *scale, float(r) *scale)

				transform        = Transform()
				transform.origin = hex_to_world(q, r)

				## random hex rotation (except water)
				if noise_value >.12:
					var random_rotation = deg2rad(randi() %6 *60)
					transform.basis = Basis(Vector3(0, 1, 0), random_rotation)


				if noise_value >.5 and randf() <.40:
					instance  = tiles_def["mountain"].instance()

				elif noise_value >.24 and randf() <.6:
					instance  = tiles_def["hill"].instance()

				elif noise_value >.12:
					instance  = tiles_def["flat"].instance()

				else:
					instance  = tiles_def["water"].instance()
					transform.origin.y -=  .1
#				hex_map_data[Vector2(q, r)] = data

				instance.transform = transform
				instance.add_to_group("hex")
				add_child(instance)






func add_tile(type:String, corr:=0.0) -> void:
	var tween           :  SceneTreeTween
	var instance        :  StaticBody
	var transform       := Transform()
	var random_rotation  = deg2rad(randi() %6 *60)

	match type:
		"flat":
			hex_height = 1
			instance = tiles_def[type].instance()
		"hill":
			hex_height =  rand_range(1.1, 1.2)
			instance = tiles_def[type].instance()
		"mountain":
			hex_height =  rand_range(1.32, 1.46)
			instance = tiles_def[type].instance()


	transform.basis      = Basis(Vector3(0, 1, 0), random_rotation)
	transform.origin     = cam.hex_pos
	if corr != 0:
		transform.origin += Vector3(0, corr, 0)

	instance.scale       = Vector3(0,0,0)
	instance.transform   = transform
	cam.hex              = instance
	add_child(instance)

	var scale  = Vector3(1, 1, 1)
	scale.y *= 1.6

	if tween:
		tween.stop()
#		yield(get_tree().create_timer(0.02), "timeout")
	tween  = get_tree().create_tween().set_trans(Tween.TRANS_SINE)
	tween.tween_property(instance, "scale", scale *1.22, .28)
	tween.tween_property(instance, "scale", Vector3(1, hex_height ,1), 1.26)
	tween.play()





func hex_to_world(xx: int, yy: int) -> Vector3:
	var x = hex_radius * 3 * .5 * yy
	var z = hex_radius * sqrt(3) * (xx + yy * .5)
	return Vector3(x, 0, z)
