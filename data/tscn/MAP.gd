extends Node3D

signal map_ready

@onready var cam        := $"%Cam"
@onready var map_radius : int = $"../".map_radius


var LightCycle     :  DayNightLightCycle

var hex_radius     := 2
var noise          :  FastNoiseLite
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






func hex_prepare(coords: Vector2, force_cat:= "", corr:= 0.0) -> void:
	var instance   :  StaticBody3D
	var cat  = instances_data[coords][1] if force_cat == "" else force_cat

	## single tile place logic:
	if force_cat != "":
		instance  = tiles_def[cat][hex_roulette(cat)].instantiate()
		instance.transform  = cam.hex.transform
		instance.add_to_group("hex")
		cam.hex.queue_free()
		cam.hex  = instance

		hex_draw({"1": [instance, cat]})

		if corr != 0:
			instance.transform.origin += Vector3(0, corr, 0)
	else:
		instance  = instances_data[coords][0]

	if cat != "water":
		var random_rotation       = deg_to_rad(randi() %6 *60)
		instance.transform.basis  = Basis(Vector3(0, 1, 0), random_rotation)

	add_child(instance)






func hex_draw(instances_list:Dictionary, full_map_gen:=false) -> void:
	var iletego     := 0  #  hex num
	var instance    :  StaticBody3D
	var hex_h       :  float
	var start_scale :  Vector3
	var t_geo       := get_tree().create_tween().set_parallel().set_trans(1).set_ease(1)
	var t_h2o       := get_tree().create_tween().set_parallel().set_trans(1).set_ease(2)

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
	for data in instances_list.values():
		var scale   := Vector3(1, 1, 1)
		var def_pos :  Vector3

		instance        = data[0]
		instance.scale  = start_scale

		if data[1] == "water" && full_map_gen:
			def_pos  = instance.transform.origin
			instance.transform.origin -= Vector3(0, -1.64, 0)
			instance.scale.x  = 3.6
			instance.scale.z  = 3.6


		## ANIM PHASE 1:
		if data[1] != "water":
			scale.y *= 2.6
			t_geo.tween_property(instance, "scale", scale *1.32, randf_range(.4, 1.2))
		else:
			t_h2o.tween_property(instance, "scale", Vector3(1,1,1), randf_range(1.1, 1.2))
			t_h2o.tween_property(instance, "transform:origin", def_pos, 1.1)

	t_geo.chain()


	## ANIM PHASE 2:
	for data in instances_list.values():
		match data[1]:
			"flat":
				hex_h  = .6
			"hill":
				hex_h  = randf_range(1.82, 2.2)
			"mountain":
				hex_h  = randf_range(.68, 1.34)

		instance  = data[0]
		if data[1] != "water":
			t_geo.tween_property(instance, "scale", Vector3(1, hex_h, 1), randf_range(.8, 2.6))


	##  PREPS:
	if full_map_gen:
		await get_tree().idle_frame
		emit_signal("map_ready")
		print(iletego)

#	if not t_geo.is_valid():
#		t_geo.kill()
#	if not t_h2o.is_valid():
#		t_h2o.kill()






func generate_instances() -> void:
	for q in range(-map_radius, map_radius + 1):
		for r in range(-map_radius, map_radius + 1):
			var s := -q -r
			if abs(s) <= map_radius:
				var noise_val = noise.get_noise_2d(float(q), float(r))
				var data      = define_hex_type_from_noise(noise_val, q, r)
				instances_data[Vector2(q, r)]  = data

	hex_draw(instances_data, true)






func generate_noise_map() -> void:
	noise  = FastNoiseLite.new()
	noise.seed         = randi()
	noise.fractal_octaves      = 8
	noise.period       = randf_range(5, 6) + (map_radius * .01)
	noise.persistence  = .04
	noise.lacunarity   = 1

	generate_instances()






func define_hex_type_from_noise(noise_value:=.16, q:=0, r:=0) -> Array:
	var transform := Transform3D()
	var instance  :  StaticBody3D
	var cat       :  String

	transform.origin    = hex_to_world(q, r)

	if noise_value >.64 and randf() <.4:
		cat = "mountain"

	elif noise_value >.36 and randf() <.4:
		cat = "hill"

	elif noise_value >.22:
		cat = "flat"

	else:
		cat = "water"
		transform.origin.y -=  .1

	var type = hex_roulette(cat)
	instance  = tiles_def[cat][type].instantiate()

	instance.transform  = transform
	instance.add_to_group("hex")

	return [instance, cat]





func hex_roulette(cat:String) ->int:
	var type : int

	if tiles_def[cat].size() > 1:
		type  = int(round(randf_range(0, 1)))
	else:
		type  = 0

	return type






func hex_to_world(rr: int, qq: int) -> Vector3:
	var r = hex_radius * 3 * .5 * qq
	var q = hex_radius * sqrt(3) * (rr + qq * .5)
	return Vector3(r, 0, q)
