extends Spatial


var visual_data := [
	["flat01", MultiMeshInstance.new()],
	["hill01", MultiMeshInstance.new()],
	["water", MultiMeshInstance.new()],
	["mountain01", MultiMeshInstance.new()]
]

var noise      := OpenSimplexNoise.new()
var hex_size   := 2
var map_data   := []
var hex_height  = 1.0



var mountain_amount := 20






func _ready() -> void:
	randomize()
	var LightCycle := DayNightLightCycle.new()

	noise.seed = randi()  # Losowy seed
	noise.octaves = rand_range(4, 5)
	noise.period = rand_range(12, 46)
	noise.persistence = rand_range(6, 16)

	map_gen(80, 80)
	add_child(LightCycle)






func map_gen(s1: int, s2: int) -> void:
	map_data.resize(s1)

	for x in range(0, s1):
		map_data[x] = []
		for y in range(0, s2):
			var transform = Transform()
			transform.origin = hex_to_world(x, y)

			var random_rotation = deg2rad(randi() % 6 * 60)
			transform.basis = Basis(Vector3(0, 1, 0), random_rotation)

			# Skalowanie koordynat dla większej zmienności(?)
			var noise_value = noise.get_noise_2d(float(x) * .4, float(y) * .4)

			# Korekta progów w zależności od wartości szumu Perlin'a
			if noise_value > .3 and randf() < .2:
				map_data[x].append({"type": "hill", "transform": transform})
			elif noise_value > 0.12:
				map_data[x].append({"type": "flat", "transform": transform})
			else:
				map_data[x].append({"type": "water", "transform": transform})

			if noise_value > .52 and randf() > .6:
				map_data[x][y] = ({"type": "mountain", "transform": transform})

#	generate_mountains()
	multimesh_factory()




func generate_mountains() -> void:
	for i in range(mountain_amount):
		var x = randi() % 80
		var y = randi() % 80

		if x >= 0 and x < 80 and y >= 0 and y < 80:
			if map_data[x][y]["type"] != "mountain":
				var transform = Transform()
				var random_rotation = deg2rad(randi() % 6 * 60)

				transform.origin = hex_to_world(x, y)
				transform.basis = Basis(Vector3(0, 1, 0), random_rotation)
				map_data[x][y] = {"type": "mountain", "transform": transform}




func multimesh_factory() -> void:
	var material_flat = SpatialMaterial.new()
	var material_water = SpatialMaterial.new()
	var material_mountain = SpatialMaterial.new()

	# flat01:
	material_flat.albedo_color = Color(.92, 1, .8)
	material_flat.roughness = .9
	material_flat.metallic = .0
	material_flat.vertex_color_use_as_albedo = true

	# water01:
	material_water.albedo_color = Color(.2, .4, .8)
	material_water.roughness = .6
	material_water.metallic = .2

	# mountain01
	material_mountain.albedo_color = Color(.82, .9, .7)
	material_mountain.roughness = 1
	material_mountain.metallic = .1


	var flat_count = 0
	var hill_count = 0
	var water_count = 0
	var mountain_count = 0

	for row in map_data:
		for tile in row:
			match tile["type"]:
				"flat":
					flat_count += 1
				"hill":
					hill_count += 1
				"water":
					water_count += 1
				"mountain":
					mountain_count += 1

	# flat01:
	visual_data[0][1].multimesh = MultiMesh.new()
	visual_data[0][1].multimesh.mesh = load("res://data/models/map/tile/flat01.obj")
	visual_data[0][1].multimesh.transform_format = MultiMesh.TRANSFORM_3D
	visual_data[0][1].multimesh.color_format = MultiMesh.COLOR_FLOAT
	visual_data[0][1].material_override = material_flat
	visual_data[0][1].multimesh.instance_count = flat_count

	# hill01:
	visual_data[1][1].multimesh = MultiMesh.new()
	visual_data[1][1].multimesh.mesh = load("res://data/models/map/tile/hill01.obj")
	visual_data[1][1].multimesh.transform_format = MultiMesh.TRANSFORM_3D
	visual_data[1][1].multimesh.color_format = MultiMesh.COLOR_FLOAT
	visual_data[1][1].material_override = material_flat
	visual_data[1][1].multimesh.instance_count = hill_count

	# water:
	visual_data[2][1].multimesh = MultiMesh.new()
	visual_data[2][1].multimesh.mesh = load("res://data/models/map/tile/flat01.obj")
	visual_data[2][1].multimesh.transform_format = MultiMesh.TRANSFORM_3D
	visual_data[2][1].multimesh.color_format = MultiMesh.COLOR_FLOAT
	visual_data[2][1].material_override = material_water
	visual_data[2][1].multimesh.instance_count = water_count

	# mountain01:
	visual_data[3][1].multimesh = MultiMesh.new()
	visual_data[3][1].multimesh.mesh = load("res://data/models/map/tile/mountain01.obj")
	visual_data[3][1].multimesh.transform_format = MultiMesh.TRANSFORM_3D
	visual_data[3][1].multimesh.color_format = MultiMesh.COLOR_FLOAT
	visual_data[3][1].material_override = material_mountain
	visual_data[3][1].multimesh.instance_count = mountain_count


	var i_flat = 0
	var i_hill = 0
	var i_water = 0
	var i_mountain = 0

	for row in map_data:
		for tile in row:
#			tile  = col["type"]
			match tile["type"]:
				"flat":
					visual_data[0][1].multimesh.set_instance_transform(i_flat, tile["transform"])
					i_flat += 1
				"hill":
					visual_data[1][1].multimesh.set_instance_transform(i_hill, tile["transform"])
					i_hill += 1
				"water":
					tile["transform"].origin.y -= .4
					visual_data[2][1].multimesh.set_instance_transform(i_water, tile["transform"])
					i_water += 1
				"mountain":
#					tile["transform"].origin.y += .22
					visual_data[3][1].multimesh.set_instance_transform(i_mountain, tile["transform"])
					i_mountain += 1

	add_child(visual_data[0][1])  # plains
	add_child(visual_data[1][1])  # hills
	add_child(visual_data[2][1])  # water
	add_child(visual_data[3][1])  # mountains






func hex_to_world(xx: int, yy: int) -> Vector3:
	var x = hex_size * 3 * .5 * yy
	var z = hex_size * sqrt(3) * (xx + yy * .5)
	return Vector3(x, 0, z)
