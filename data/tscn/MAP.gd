extends Spatial


onready var cam := $"%Cam"

signal map_ready
var LightCycle     :  DayNightLightCycle
var map_radius     := 16
var hex_radius     := 2
var noise          :  OpenSimplexNoise
var instances_data :  Dictionary


var tiles_def := {
	"flat":     preload("res://data/objects/map_tiles/flat01.tscn"),
	"hill":     preload("res://data/objects/map_tiles/hill01.tscn"),
	"mountain": preload("res://data/objects/map_tiles/mountain01.tscn"),
	"water":    preload("res://data/objects/map_tiles/water01.tscn")
}






func _ready() -> void:
	randomize()
	LightCycle  = DayNightLightCycle.new()

	generate_noise_map()
	add_child(LightCycle)



func hex_prepare(coords: Vector2, force_type:= "", corr:= 0.0) -> void:
#	var tween      := get_tree().create_tween().set_trans(1).set_ease(1)
#	var hex_h      :  float
	var instance   :  StaticBody
#	var mult       :  float
#	var mult2      :  float

	var type  = instances_data[coords][1] if force_type == "" else force_type

	if force_type != "":
		instance  = tiles_def[type].instance()
		instance.transform  = cam.hex.transform
		instance.add_to_group("hex")
		cam.hex.queue_free()
		cam.hex  = instance

#		yield(get_tree(), "idle_frame")
		hex_draw({"1": [instance, type]})

#		mult     = 1
#		mult2    = 1

		if corr != 0:
			instance.transform.origin += Vector3(0, corr, 0)
	else:
		instance  = instances_data[coords][0]
#		mult      = 4
#		mult2     = 1.4

	add_child(instance)





func hex_draw(instances_list:Dictionary, full_map_gen:=false) -> void:
	var hex_h       :  float
	var start_scale :  Vector3
	var tween       := get_tree().create_tween().set_parallel().set_trans(1).set_ease(1)

	if full_map_gen:
		start_scale  = Vector3(0,0,0)
		for q in range(-map_radius, map_radius + 1):
			for r in range(-map_radius, map_radius + 1):
				var s := -q -r
				if abs(s) <= map_radius:
					hex_prepare(Vector2(q, r))
	else:
		start_scale  = Vector3(1,0,1)

	for key in instances_list.keys():
		var instance   :  StaticBody  = instances_list[key][0]
		var scale      := Vector3(1, 1, 1)
		instance.scale  = start_scale

		match instances_list[key][1]:
			"flat", "water":
				hex_h  = 1
			"hill":
				hex_h  = rand_range(1.1, 1.2)
			"mountain":
				hex_h  = rand_range(1.32, 1.46)

		if instances_list[key][1] != "water":
			scale.y  = 2.2
			tween.tween_property(instance, "scale", scale *1.22, .4)

		else:
			tween.tween_property(instance, "scale", scale, rand_range(.2, .8))

	tween.chain()
	for key in instances_list.keys():
		var instance   :  StaticBody  = instances_list[key][0]
		tween.tween_property(instance, "scale", Vector3(1, hex_h, 1), rand_range(1.2, 2.2))

	if full_map_gen:
		yield(get_tree(), "idle_frame")
		emit_signal("map_ready")






func generate_noise_map() -> void:
	noise  = OpenSimplexNoise.new()
	noise.seed         = randi()
	noise.octaves      = int(rand_range(3, 4))
	noise.period       = rand_range(2.8, 4.2)
	noise.persistence  = rand_range(.6, 1)
	noise.lacunarity   = rand_range(.8, 4) -noise.period *.25

	generate_instances()





var p_scale     := 1 - map_radius * .012  ## perlin scale

func generate_instances() -> void:
	for q_ in range(-map_radius, map_radius + 1):
		for r_ in range(-map_radius, map_radius + 1):
			var s := -q_ -r_
			if abs(s) <= map_radius:
				var noise_val = noise.get_noise_2d(float(q_) *p_scale, float(r_) *p_scale)
				var data      = define_hex_type_from_noise(noise_val, q_, r_)
				instances_data[Vector2(q_, r_)]  = data

	hex_draw(instances_data, true)






func define_hex_type_from_noise(noise_value:=.16, q_:=0, r_:=0) -> Array:
	var transform := Transform()
	var instance  :  StaticBody
	var type      :  String

	transform.origin    = hex_to_world(q_, r_)

	if noise_value >.5 and randf() <.40:
		type = "mountain"
		instance  = tiles_def[type].instance()

	elif noise_value >.24 and randf() <.6:
		type = "hill"
		instance  = tiles_def[type].instance()

	elif noise_value >.12:
		type = "flat"
		instance  = tiles_def[type].instance()

	else:
		type = "water"
		instance  = tiles_def[type].instance()
		transform.origin.y -=  .1

	if type != "water":
		var random_rotation  = deg2rad(randi() %6 *60)
		transform.basis      = Basis(Vector3(0, 1, 0), random_rotation)

	instance.transform  = transform
	instance.add_to_group("hex")

	return [instance, type]





func hex_to_world(xx: int, yy: int) -> Vector3:
	var x = hex_radius * 3 * .5 * yy
	var z = hex_radius * sqrt(3) * (xx + yy * .5)
	return Vector3(x, 0, z)
