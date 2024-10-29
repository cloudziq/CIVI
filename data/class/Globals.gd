extends Node


var revision  = 1
var CONFIG
var config_path




var window := Vector2(
	ProjectSettings.get_setting("display/window/size/width" ),
	ProjectSettings.get_setting("display/window/size/height")
	)






func set_defaults():
	CONFIG = {
		"sound_vol":      1,
		"music_vol":      0.4
	}






func save_config():
#	var password = "87643287643876243876241"
#	var key = password.sha256_buffer()
	var config = ConfigFile.new()

	config.set_value("config", "save_version", revision)
	config.set_value("config", "settings", CONFIG)

	config.save(config_path)
#	config.save_encrypted(config_path, key)






func load_config():
#	var password = "87643287643876243876241"
#	var key = password.sha256_buffer()
	var config = ConfigFile.new()

	var system = OS.get_name()
	match system:
		"Windows", "X11":
			config_path = "res://game_config.cfg"
		"Android":
			config_path = "user://config.cfg"

	var check  = config.load(config_path)
#	var check  = config.load_encrypted(config_path, key)
	if check != OK:
		set_defaults()
	else:
		if config.get_value("config", "save_version") == revision:
			CONFIG = config.get_value("config", "settings")
		else:
			set_defaults()
