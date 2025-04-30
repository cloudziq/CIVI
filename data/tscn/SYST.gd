# Dziq Entertainment Corporation 2024 - 3027
# v0.1^-gamma


extends Node3D
enum screens {normal, dev, rec}

@export var map_radius  : int    = 20
@export var day_length  : float  = 60   ## in seconds
@export var screen: screens      = screens.normal






func _ready() -> void:
	randomize()
#	G.load_config()
	window_prepare()
	add_child(preload("res://data/tscn/MAP.tscn").instantiate())






func window_prepare() -> void:
	var display_size = DisplayServer.screen_get_size()
	var window_size  = G.window

	if screen == screens.normal:
		window_size *= Vector2(4, 4)
	elif screen == screens.dev:
		window_size *= Vector2(.72, .72)
	else:
		window_size *= Vector2(.44, .44)

	if display_size.y <= window_size.y:
		var scale_ratio = window_size.x / (display_size.x - 100)
		window_size.x /= scale_ratio ; window_size.y /= scale_ratio

	get_window().size = window_size
	window_size.y += 64
	get_window().position = display_size * .5 - window_size * .5
