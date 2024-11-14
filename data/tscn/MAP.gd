extends Spatial


export var map_radius := 40
signal map_ready

onready var cam := $"%Cam"


var LightCycle     :  DayNightLightCycle

var hex_radius     := 2
var noise          :  OpenSimplexNoise
var instances_data :  Dictionary


var tiles_def := {
	"flat":     [preload("res://data/tscn/map_tiles/flat01.tscn")],
	"hill":     [
		preload("res://data/tscn/map_tiles/hill01.tscn"),
		preload("res://data/tscn/map_tiles/hill02.tscn")
	],
	"mountain": [preload("res://data/tscn/map_tiles/mountain01.tscn")],
	"water":    [preload("res://data/tscn/map_tiles/water01.tscn")]
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

	## single tile place logic:
	if force_type != "":
		instance  = tiles_def[type][0].instance()
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
	var iletego     := 0  #  hex num
	var instance    :  StaticBody
	var hex_h       :  float
	var start_scale :  Vector3
	var t_geo       := get_tree().create_tween().set_parallel().set_trans(1).set_ease(1)
	var t_h2o       := get_tree().create_tween().set_parallel().set_trans(10).set_ease(2)

	if full_map_gen:
		start_scale  = Vector3(.02, .02, .02)
		for q in range(-map_radius, map_radius + 1):
			for r in range(-map_radius, map_radius + 1):
				var s := -q -r
				if abs(s) <= map_radius:
					iletego += 1
					hex_prepare(Vector2(q, r))
	else:
		start_scale  = Vector3(1, .02, 1)

	## ANIM PREPARATION:
	for key in instances_list.keys():
		instance       = instances_list[key][0]
		var scale     := Vector3(1, 1, 1)
#		var def_scale := scale
		var def_pos   :  Vector3

		match instances_list[key][1]:
			"flat":
				hex_h  = 1
			"hill":
				hex_h  = rand_range(1.25, 1.84)
			"mountain":
				hex_h  = rand_range(.88, 1.46)
			"water":
				hex_h  = 1
				def_pos  = instance.transform.origin
				instance.transform.origin -= Vector3(0, -2, 0)
				start_scale.x  = 3
				start_scale.z  = 3

		instance.scale  = start_scale


		## ANIM PHASE 1:
		if instances_list[key][1] != "water":
			scale.y *= 2.2
			t_geo.tween_property(instance, "scale", scale *1.32, rand_range(.2, 1.2))
		else:
			t_h2o.tween_property(instance, "scale", scale, rand_range(1.1, 1.2))
			t_h2o.tween_property(instance, "transform:origin", def_pos, 1.1)

	t_geo.chain()
	t_h2o.chain()

	## ANIM PHASE 2:
	for key in instances_list.keys():
		instance  = instances_list[key][0]

		if instances_list[key][1] != "water":
			t_geo.tween_property(instance, "scale", Vector3(1, hex_h, 1), rand_range(.8, 2.6))
#		else:
#			t_h2o.tween_property(instance, "scale", Vector3(1, 1, 1), rand_range(1, 2))

	if full_map_gen:
		yield(get_tree(), "idle_frame")
		emit_signal("map_ready")
		print(iletego)

	if not t_geo.is_running():
		t_geo.kill()
	if not t_h2o.is_running():
		t_h2o.kill()





func map_draw() -> void:
	pass





func generate_noise_map() -> void:
	noise  = OpenSimplexNoise.new()
	noise.seed         = randi()
	noise.octaves      = 4
	noise.period       = rand_range(.4, .6) - (map_radius * .2)
	noise.persistence  = rand_range(.01, .04)
	noise.lacunarity   = rand_range(.2, 1)

	generate_instances()






func generate_instances() -> void:
	for q in range(-map_radius, map_radius + 1):
		for r in range(-map_radius, map_radius + 1):
			var s := -q -r
			if abs(s) <= map_radius:
				var noise_val = noise.get_noise_2d(float(q), float(r))
				var data      = define_hex_type_from_noise(noise_val, q, r)
				instances_data[Vector2(q, r)]  = data

	hex_draw(instances_data, true)






func define_hex_type_from_noise(noise_value:=.16, q_:=0, r_:=0) -> Array:
	var transform := Transform()
	var instance  :  StaticBody
	var cat       :  String

	transform.origin    = hex_to_world(q_, r_)

	if noise_value >.84 and randf() <.40:
		cat = "mountain"

	elif noise_value >.44 and randf() <.6:
		cat = "hill"

	elif noise_value >.22:
		cat = "flat"

	else:
		cat = "water"
		transform.origin.y -=  .1

	var type = hex_roulette(cat)
	instance  = tiles_def[cat][type].instance()


	if cat != "water":
		var random_rotation  = deg2rad(randi() %6 *60)
		transform.basis      = Basis(Vector3(0, 1, 0), random_rotation)

	instance.transform  = transform
	instance.add_to_group("hex")

	return [instance, cat]





func hex_roulette(cat:String) ->int:
	var type : int

	if tiles_def[cat].size() > 1:
		type  = int(round(rand_range(0, 1)))
		print(type)
	else:
		type  = 0

	return type






func hex_to_world(rr: int, qq: int) -> Vector3:
	var r = hex_radius * 3 * .5 * qq
	var q = hex_radius * sqrt(3) * (rr + qq * .5)
	return Vector3(r, 0, q)
