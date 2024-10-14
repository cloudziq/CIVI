extends Spatial


var terrain_data := [
	["flat01", MultiMeshInstance.new()],
	["hill01", MultiMeshInstance.new()]
]


var hex_size = 2
var hex_height = 1.0
var map_data = []  # Tutaj zapiszemy dane o każdym hexie






func _ready() -> void:
	map_gen(40, 40)






func map_gen(s1: int, s2: int) -> void:
	var transform : Transform

	for x in range(0, s1):
		for y in range(0, s2):
			transform = Transform()
			transform.origin = hex_to_world(x, y)

			var random_rotation = deg2rad(randi() % 6 * 60)
			transform.basis = Basis(Vector3(0, 1, 0), random_rotation)

			if randf() < 0.2:
				map_data.append({"type": "hill", "transform": transform})
			else:
				map_data.append({"type": "flat", "transform": transform})

	multimesh_factory()






func multimesh_factory() -> void:
	var material_flat  = SpatialMaterial.new()
	var material_hill  = SpatialMaterial.new()

	#  flat01 mat:
	material_flat.albedo_color  = Color(0.6, 1, 0.3)
	material_flat.roughness     = .9
	material_flat.metallic      =  1

	#  hill01 mat:
	material_hill.albedo_color  = Color(0.6, 1, 0.3)
	material_hill.roughness     = .9
	material_hill.metallic      =  1

	var flat_count = 0
	var hill_count = 0

	for tile in map_data:
		if tile["type"] == "flat":
			flat_count += 1
		else:
			hill_count += 1

	#  flat01:
	terrain_data[0][1].multimesh       = MultiMesh.new()
	terrain_data[0][1].multimesh.mesh  = load("res://data/models/map/tile/flat01.obj")
	terrain_data[0][1].multimesh.transform_format  = MultiMesh.TRANSFORM_3D
	terrain_data[0][1].multimesh.instance_count    = flat_count
	terrain_data[0][1].material_override           = material_flat

	#  hill01:
	terrain_data[1][1].multimesh       = MultiMesh.new()
	terrain_data[1][1].multimesh.mesh  = load("res://data/models/map/tile/hill01.obj")
	terrain_data[1][1].multimesh.transform_format  = MultiMesh.TRANSFORM_3D
	terrain_data[1][1].multimesh.instance_count    = hill_count
	terrain_data[1][1].material_override           = material_hill

	var i_flat = 0
	var i_hill = 0

	for tile in map_data:
		if tile["type"] == "flat":
			terrain_data[0][1].multimesh.set_instance_transform(i_flat, tile["transform"])
			i_flat += 1
		else:
			terrain_data[1][1].multimesh.set_instance_transform(i_hill, tile["transform"])
			i_hill += 1

	add_child(terrain_data[0][1])
	add_child(terrain_data[1][1])






func hex_to_world(r, q) -> Vector3:
	var x = hex_size * 3 * .5 * q
	var z = hex_size * sqrt(3) * (r + q * .5)
	return Vector3(x, 0, z)
