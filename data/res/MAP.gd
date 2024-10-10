extends Spatial


#onready var hex_  = preload("res://data/models/hex_tile.tscn"); var hex

var tile_grass  = MultiMeshInstance.new()

var hex_size    = 2
var hex_height  = 1.0


var map_data : Array






func _ready() -> void:
	map_gen(100, 100)






func map_gen(s1: int, s2: int) -> void:
	var transform
	var material

	tile_grass.multimesh                   = MultiMesh.new()
	tile_grass.multimesh.mesh              = load("res://data/models/map/tile/hex_tile.obj")
	tile_grass.multimesh.transform_format  = MultiMesh.TRANSFORM_3D
#	tile_grass.multimesh.color_format      = MultiMesh.COLOR_FLOAT
	tile_grass.multimesh.instance_count    = s1 * s2

	material = SpatialMaterial.new()
	material.albedo_color         = Color(.4, 1, .2)
	material.roughness = 1
	material.metallic  = .9
	tile_grass.material_override  = material

	var i  = 0
	for x in range(0, s1):
		for y in range(0, s2):
			transform         = Transform()
			transform.origin  = hex_to_world(x, y)
			tile_grass.multimesh.set_instance_transform(i, transform)
			i += 1

	add_child(tile_grass)







func hex_to_world(q, r):
	var x  = hex_size * 3 * .5 * q
	var z  = hex_size * sqrt(3) * (r + q * .5)

	return Vector3(x, 0, z)
