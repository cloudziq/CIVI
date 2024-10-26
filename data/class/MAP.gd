extends Spatial


var map_size        := Vector2(60, 60)


## Holders:
var flat_count     := 0
var hill_count     := 0
var water_count    := 0
var mountain_count := 0
var noise          := OpenSimplexNoise.new()
var hex_radius     := 2
var map_data       := []


var visual_data    := {
	"flat01":     MultiMeshInstance.new(),
	"hill01":     MultiMeshInstance.new(),
	"water01":    MultiMeshInstance.new(),
	"mountain01": MultiMeshInstance.new(),
}






func _ready() -> void:
	randomize()
	var LightCycle    := DayNightLightCycle.new()

	noise.seed         = randi()
	noise.octaves      = int(rand_range(3, 6))
	noise.period       = rand_range(5, 8) * noise.octaves
	noise.persistence  = rand_range(8, 12) * noise.octaves

	map_gen(map_size)
	add_child(LightCycle)






func map_gen(size:Vector2) -> void:
	var s1 := int(size.x)
	var s2 := int(size.y)

	map_data.resize(s1)

	for x in range(s1):
		map_data[x]  = []
		for y in range(s2):
			# Skalowanie koordynat dla większej zmienności(?)
			var noise_value = noise.get_noise_2d(float(x) * .4, float(y) * .4)

			var transform = Transform()
			transform.origin = hex_to_world(x, y)

			if noise_value > .12:
				var random_rotation = deg2rad(randi() % 6 * 60)
				transform.basis = Basis(Vector3(0, 1, 0), random_rotation)


			if noise_value > .44 and randf() > .66:
				map_data[x].append(
					{"type": "mountain01", "transform": transform, "id": mountain_count})
				mountain_count += 1

			elif noise_value > .3 and randf() < .2:
				map_data[x].append(
					{"type": "hill01", "transform": transform, "id": hill_count})
				hill_count += 1

			elif noise_value > 0.12:
				map_data[x].append(
					{"type": "flat01", "transform": transform, "id": flat_count})
				flat_count += 1

			else:
				map_data[x].append(
					{"type": "water01", "transform": transform, "id": water_count})
				water_count += 1

	multimesh_define()
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






func multimesh_define() -> void:
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
	var i :  MultiMeshInstance

	# flat01:
	i  = visual_data["flat01"]
	i.multimesh                   = MultiMesh.new()
	i.multimesh.mesh              = load("res://data/models/map/tile/flat01.obj")
	i.multimesh.transform_format  = MultiMesh.TRANSFORM_3D
	i.multimesh.color_format      = MultiMesh.COLOR_FLOAT
	i.multimesh.instance_count    = flat_count
	i.material_override           = material_flat

	# hill01:
	i  = visual_data["hill01"]
	i.multimesh                   = MultiMesh.new()
	i.multimesh.mesh              = load("res://data/models/map/tile/hill01.obj")
	i.multimesh.transform_format  = MultiMesh.TRANSFORM_3D
	i.multimesh.color_format      = MultiMesh.COLOR_FLOAT
	i.multimesh.instance_count    = hill_count
	i.material_override           = material_flat

	# water01:
	i  = visual_data["water01"]
	i.multimesh                   = MultiMesh.new()
	i.multimesh.mesh              = load("res://data/models/map/tile/water01.obj")
	i.multimesh.transform_format  = MultiMesh.TRANSFORM_3D
	i.multimesh.color_format      = MultiMesh.COLOR_FLOAT
	i.multimesh.instance_count    = water_count
	i.material_override           = material_water

	#  mountain01:
	i = visual_data["mountain01"]
	i.multimesh                   = MultiMesh.new()
	i.multimesh.mesh              = load("res://data/models/map/tile/mountain01.obj")
	i.multimesh.transform_format  = MultiMesh.TRANSFORM_3D
	i.multimesh.color_format      = MultiMesh.COLOR_FLOAT
	i.multimesh.instance_count    = mountain_count
	i.material_override           = material_mountain


	var i_flat  := 0
	var i_hill  := 0
	var i_water := 0
	var i_mount := 0

	for row in map_data:
		for tile in row:
			match tile["type"]:
				"flat01":
					visual_data["flat01"].multimesh.set_instance_transform(
						i_flat, tile["transform"])
					i_flat += 1
				"hill01":
					visual_data["hill01"].multimesh.set_instance_transform(
						i_hill, tile["transform"])
					i_hill += 1
				"water01":
					tile["transform"].origin.y -= .4
					visual_data["water01"].multimesh.set_instance_transform(
						i_water, tile["transform"])
					i_water += 1
				"mountain01":
					visual_data["mountain01"].multimesh.set_instance_transform(
						i_mount, tile["transform"])
					i_mount += 1



#	for instance in visual_data:
#		add_child(instance[1])
	add_child(visual_data["flat01"])      # plains
	add_child(visual_data["hill01"])      # hills
	add_child(visual_data["water01"])     # water
	add_child(visual_data["mountain01"])  # mountains

	$Camera.reload_map_data()




func hex_to_world(xx: int, yy: int) -> Vector3:
	var x = hex_radius * 3 * .5 * yy
	var z = hex_radius * sqrt(3) * (xx + yy * .5)
	return Vector3(x, 0, z)
