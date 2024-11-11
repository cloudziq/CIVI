extends Spatial


onready var cam := $"%Cam"

var LightCycle     :  DayNightLightCycle
var map_radius     := 32
var hex_radius     := 2
var noise          :  OpenSimplexNoise
var instances_data :  Dictionary

var allow_map_draw     := false
var q : int  ;  var qq :  int
var r : int  ;  var rr :  int


var tiles_def := {
	"flat":     preload("res://data/objects/map_tiles/flat01.tscn"),
	"hill":     preload("res://data/objects/map_tiles/hill01.tscn"),
	"mountain": preload("res://data/objects/map_tiles/mountain01.tscn"),
	"water":    preload("res://data/objects/map_tiles/water01.tscn")
}






func _ready() -> void:
	q  = -map_radius ;  qq  = map_radius +1
	r  = -map_radius ;  rr  = map_radius +1
	randomize()
	LightCycle  = DayNightLightCycle.new()

	generate_noise_map()
	add_child(LightCycle)






func _physics_process(_dt:float) -> void:
	if allow_map_draw:
#		for q_ in range(-map_radius, map_radius + 1):
#			for r_ in range(-map_radius, map_radius + 1):
#				var s := -q_ -r_
#				if abs(s) <= map_radius:
#					draw_hex(Vector2(q_, r_))
#				else:
#					allow_map_draw  = false
		r += 1
		if r == rr :
			q += 1
			r = -map_radius
			if q == qq:
				allow_map_draw  = false
				q = -map_radius
		else:
			var s := -q -r
			if abs(s) <= map_radius:
				draw_hex(Vector2(q, r))










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

	allow_map_draw  = true






func draw_hex(coords: Vector2, force_type:= "", corr:= 0.0) -> void:
	var tween      : SceneTreeTween
	var hex_height : float
	var instance   : StaticBody

	var type  = instances_data[coords][1] if force_type == "" else force_type

	match type:
		"flat":
			hex_height = 1
		"hill":
			hex_height =  rand_range(1.1, 1.2)
		"mountain":
			hex_height =  rand_range(1.32, 1.46)
		"water":
			hex_height = 1


	if force_type != "":
		instance  = tiles_def[type].instance()
		instance.transform  = instances_data[coords][0].transform
		instance.add_to_group("hex")
		instances_data[coords][0].queue_free()
#		cam.hex  = new_instance

		if corr != 0:
			instance.transform.origin += Vector3(0, corr, 0)
	else:
		instance  = instances_data[coords][0]

	add_child(instance)

	var scale  = Vector3(1, 1, 1)
	instance.scale  = Vector3(0,0,0)
	tween  = get_tree().create_tween().set_trans(Tween.TRANS_SINE)

	if type != "water":
		scale.y   *= 2.2
		tween.tween_property(instance, "scale", scale *1.22, .28)
		tween.tween_property(instance, "scale", Vector3(1, hex_height, 1), 1.26)
	else:
		tween.tween_property(instance, "scale", scale, .92)







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








#func add_hex_instance() -> void:










func hex_to_world(xx: int, yy: int) -> Vector3:
	var x = hex_radius * 3 * .5 * yy
	var z = hex_radius * sqrt(3) * (xx + yy * .5)
	return Vector3(x, 0, z)
