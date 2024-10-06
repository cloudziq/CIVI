extends Spatial


onready var hex_  = preload("res://data/models/hex_tile.tscn"); var hex


var hex_size    = 2
var hex_height  = 1.0






func _ready() -> void:
#	yield(get_tree().create_timer(1), "timeout")

	for x in range(-20, 30):
		for y in range(-20, 30):
			hex           = hex_.instance()
			add_child(hex)
			hex.translation = hex_to_world(x, y)






func hex_to_world(q, r):
	var x  = hex_size * 3 * .5 * q
	var z  = hex_size * sqrt(3) * (r + q * .5)

	return Vector3(x, 0, z)


