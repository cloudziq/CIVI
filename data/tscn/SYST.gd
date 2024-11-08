# Dziq Entertainment Corporation 2024 - 3027
# v0.1^-gamma


extends Spatial


export var rec_screen  := false
export var dev_screen  := true






func _ready() -> void:
	randomize()
#	G.load_config()
	window_prepare()
	add_child(preload("res://data/tscn/MAP.tscn").instance())






func window_prepare() -> void:
	var display_size = OS.get_screen_size()
	var window_size  = G.window

	if rec_screen:
		window_size *= Vector2(.52, .52)
	elif dev_screen:
		window_size *= Vector2(.65, .65)
	else:
		window_size *= Vector2(4, 4)

	if display_size.y <= window_size.y:
		var scale_ratio = window_size.x / (display_size.x - 100)
		window_size.x /= scale_ratio ; window_size.y /= scale_ratio

	OS.window_size = window_size
	window_size.y += 64
	OS.window_position = display_size * .5 - window_size * .5
