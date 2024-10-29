extends Spatial


var map_radius := 60


## Holders:
var flat_count     := 0
var hill_count     := 0
var water_count    := 0
var mountain_count := 0
var noise          := OpenSimplexNoise.new()
var hex_radius     := 2
var map_data       := []


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
	noise.octaves      = int(rand_range(3, 6))
	noise.period       = rand_range(5, 8) * noise.octaves
	noise.persistence  = rand_range(8, 12) * noise.octaves

	map_gen()
	add_child(LightCycle)



#var hex_map_data = {}



func map_gen() -> void:
#	var data : Dictionary

	for q in range(-map_radius, map_radius + 1):
		for r in range(-map_radius, map_radius + 1):
			var s = -q - r

			if abs(s) <= map_radius:
				var instance : StaticBody
				var noise_value = noise.get_noise_2d(float(q) * .46, float(r) * .46)

				var transform = Transform()
				transform.origin = hex_to_world(q, r)


#				if noise_value > .12:
				var random_rotation = deg2rad(randi() % 6 * 60)
				transform.basis = Basis(Vector3(0, 1, 0), random_rotation)


				if noise_value > .44 and randf() > .66:
					instance  = tiles_def["mountain01"].instance()

				elif noise_value > .3 and randf() < .22:
					instance  = tiles_def["hill01"].instance()

				elif noise_value > .12:
					instance  = tiles_def["flat01"].instance()

				else:
					instance  = tiles_def["water01"].instance()
					transform.origin.y -= .2
#				hex_map_data[Vector2(q, r)] = data

				instance.transform = transform
				add_child(instance)

#	multimesh_factory()
#	generate_mountains()
#
#
#
#
#func generate_mountains() -> void:
#	for i in range(mountain_amount):
#		var x = randi() % int(map_size.x)
#		var y = randi() % int(map_size.y)
#
#		if x >= 0 and x < map_size.x and y >= 0 and y < map_size.y:
#			if map_data[x][y]["type"] != "mountain01":
#				var transform = Transform()
#				var random_rotation = deg2rad(randi() % 6 * 60)
#
#				transform.origin = hex_to_world(x, y)
#				transform.basis = Basis(Vector3(0, 1, 0), random_rotation)
#				map_data[x][y] = {"type": "mountain01", "transform": transform}






# creating materials and divide chunks into separate multimeshes:
func multimesh_factory() -> void:
	var material_flat     := SpatialMaterial.new()
	var material_water    := SpatialMaterial.new()
	var material_mountain := SpatialMaterial.new()

	var normal_texture  = load("res://terrain_normalmap.tres")

	# flat01 base material:
	material_flat.albedo_color                = Color(.92, 1, .8)
	material_flat.roughness                   = .9
	material_flat.metallic                    = .1
	material_flat.vertex_color_use_as_albedo  = true
	material_flat.normal_enabled              = true
	material_flat.normal_scale                = .52
	material_flat.normal_texture              = normal_texture

	# mountain01 base material:
	material_mountain.albedo_color                = Color(.92, 1, .8)
	material_mountain.roughness                   = .9
	material_mountain.metallic                    = .1
	material_mountain.vertex_color_use_as_albedo  = true
	material_mountain.normal_enabled              = true
	material_mountain.normal_scale                = 1.25
	material_mountain.normal_texture              = normal_texture

	# water01 base material:
	material_water.albedo_color                = Color(.2, .4, .8)
	material_water.roughness                   = .32
	material_water.metallic                    = .1
	material_water.metallic_specular           = .4
	material_water.vertex_color_use_as_albedo  = true
	material_water.normal_enabled              = true
	material_water.normal_scale                = .64
	material_water.normal_texture              = normal_texture


	# multimesh creation:
#	var i :  MultiMeshInstance
#
#	# flat01:
#	i  = visual_data["flat01"]
#	i.multimesh                   = MultiMesh.new()
#	i.multimesh.mesh              = load("res://data/models/map/tile/flat01.obj")
#	i.multimesh.transform_format  = MultiMesh.TRANSFORM_3D
#	i.multimesh.color_format      = MultiMesh.COLOR_FLOAT
#	i.multimesh.instance_count    = flat_count
#	i.material_override           = material_flat
#
#	# hill01:
#	i  = visual_data["hill01"]
#	i.multimesh                   = MultiMesh.new()
#	i.multimesh.mesh              = load("res://data/models/map/tile/hill01.obj")
#	i.multimesh.transform_format  = MultiMesh.TRANSFORM_3D
#	i.multimesh.color_format      = MultiMesh.COLOR_FLOAT
#	i.multimesh.instance_count    = hill_count
#	i.material_override           = material_flat
#
#	# water01:
#	i  = visual_data["water01"]
#	i.multimesh                   = MultiMesh.new()
#	i.multimesh.mesh              = load("res://data/models/map/tile/water01.obj")
#	i.multimesh.transform_format  = MultiMesh.TRANSFORM_3D
#	i.multimesh.color_format      = MultiMesh.COLOR_FLOAT
#	i.multimesh.instance_count    = water_count
#	i.material_override           = material_water
#
#	#  mountain01:
#	i = visual_data["mountain01"]
#	i.multimesh                   = MultiMesh.new()
#	i.multimesh.mesh              = load("res://data/models/map/tile/mountain01.obj")
#	i.multimesh.transform_format  = MultiMesh.TRANSFORM_3D
#	i.multimesh.color_format      = MultiMesh.COLOR_FLOAT
#	i.multimesh.instance_count    = mountain_count
#	i.material_override           = material_mountain


	# dividing raw chunk into separate chunks (each for given terrain type):
#	var raw_chunks = define_raw_chunks()

	# counting individual instances:
#	var i_flat  := 0
#	var i_hill  := 0
#	var i_water := 0
#	var i_mount := 0

#	for chunk in raw_chunks:
#		chunk_data  = chunk_data_def
#
#		for hex in chunk:
#			match hex:
#				"flat01":
#					chunk_data[hex][1] = hex["transform"]
#					i_flat += 1
#				"hill01":
#					chunk_data["hill01"].multimesh.set_instance_transform(
#						i_hill, hex["transform"])
#					i_hill += 1
#				"water01":
#					hex["transform"].origin.y -= .4
#					chunk_data["water01"].multimesh.set_instance_transform(
#						i_water, hex["transform"])
#					i_water += 1
#				"mountain01":
#					chunk_data["mountain01"].multimesh.set_instance_transform(
#						i_mount, hex["transform"])
#					i_mount += 1

#	if i_flat != 0:
#		var i  = chunk_data["flat"]
#		i["flat"][0].multimesh           = MultiMesh.new()
#		i[0].multimesh.mesh              = load("res://data/models/map/tile/flat01.obj")
#		i[0].multimesh.transform_format  = MultiMesh.TRANSFORM_3D
#		i[0].multimesh.color_format      = MultiMesh.COLOR_FLOAT
#		i[0].multimesh.instance_count    = flat_count
#		i[0].material_override           = material_flat
#		add_child(i[0])




#	for hex in chunk_data.keys():
#		var i  = hex
#		match hex:
#			"flat01":
#				i["flat01"].multimesh.set_instance_transform(
#					i_hill, hex["transform"])
#					i[0].multimesh    = MultiMesh.new()
#					i[0].multimesh.mesh              = load("res://data/models/map/tile/flat01.obj")
#					i[0].multimesh.transform_format  = MultiMesh.TRANSFORM_3D
#					i[0].multimesh.color_format      = MultiMesh.COLOR_FLOAT
#					i[0].multimesh.instance_count    = flat_count
#					i[0].material_override           = material_flat
#					add_child(i[0])

#	add_child(visual_data["flat01"])      # plains
#	add_child(visual_data["hill01"])      # hills
#	add_child(visual_data["water01"])     # water
#	add_child(visual_data["mountain01"])  # mountains

#	$Camera.reload_map_data()




func hex_to_world(xx: int, yy: int) -> Vector3:
	var x = hex_radius * 3 * .5 * yy
	var z = hex_radius * sqrt(3) * (xx + yy * .5)
	return Vector3(x, 0, z)
