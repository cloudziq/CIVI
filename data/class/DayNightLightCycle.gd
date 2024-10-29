extends     Node
class_name  DayNightLightCycle


onready var sun  : DirectionalLight = $"../%Sun"
onready var moon : DirectionalLight = $"../%Moon"
onready var env  : WorldEnvironment = $"../%Env"


## Main settings:
var day_length   := 16.0    ## in seconds
var night_length := 12.0

var sun_min_h  := -1
var sun_max_h  := -30.0
var moon_min_h := -1
var moon_max_h := -40.0
var rot_dir    := -1

var start_pos      := 80.0
var end_pos        := 280.0
var disc_start_pos := 40.0
var disc_end_pos   := disc_start_pos + 360

var moon_start_offset  = day_length - (night_length * .14)
var sun_start_offset   = night_length - (day_length * .16)

var sun_vis    := true
var moon_vis   := false


## Holders:
var sun_p       := 0.0
var moon_p      := 0.0
var disc_p      := 0.0
var sun_cycle   := 0.0
var moon_cycle  := 0.0
var disc_cycle  := 0.0


var color_table := {
	"moon": {
		"disc": [
			Color(.04, .05, .07),
			Color(.12, .18, .32),
			Color(.16, .22, .46)
		],
		"bg": [
			.32, .4, .22
		]
	},
	"sun": {
		"disc": [
			Color(.44, .22, .28),
			Color(.82, .76, .68),
			Color(.58, .54, .48)
		],
		"bg": [
			.6, 1.2, 1.6
		]
	}
}






func _ready() -> void:
	moon.light_color  = Color(0,0,0)





func _process(dt: float) -> void:
		var env_ : Environment = env.environment
		var disc_angle := 0.0

		disc_cycle += dt
		if disc_cycle < sun_start_offset + moon_start_offset:
			disc_p      = disc_cycle / (sun_start_offset + moon_start_offset)
			disc_angle  = lerp(disc_start_pos, disc_end_pos, disc_p)
			env_.background_sky_rotation_degrees.y  = disc_angle
		else:
			disc_cycle  = 0

		if sun_vis:
			if sun_cycle == 0: aura_control("sun")
			sun_cycle += dt

			if sun_cycle < day_length:
				sun_p     = sun_cycle / day_length
				if sun_cycle > moon_start_offset:
					moon_vis  = true


				var current_dist      = lerp(start_pos, end_pos, sun_p) * rot_dir
				var angle_x: float    = lerp(sun_min_h, sun_max_h, sin(sun_p * PI))
				sun.rotation_degrees  = Vector3(angle_x, current_dist, 0)

			else:
				sun_cycle  = 0
				sun_vis  = false

		if moon_vis:
			if moon_cycle == 0: aura_control("moon")
			moon_cycle += dt
			if moon_cycle < night_length:
				moon_p    = moon_cycle / night_length
				if moon_cycle > sun_start_offset:
					sun_vis  = true

				var current_dist       = lerp(start_pos, end_pos, moon_p) * rot_dir
				var angle_x: float     = lerp(moon_min_h, moon_max_h, sin(moon_p * PI))
				moon.rotation_degrees  = Vector3(angle_x, current_dist, 0)
			else:
				moon_cycle  = 0
				moon_vis  = false






func aura_control(type: String) -> void:
	var tween    := get_tree().create_tween().set_parallel(false)
	var obj      := sun if type == "sun" else moon
	var length   := day_length if type == "sun" else night_length
	var env_     :  Environment  = env.environment
	var color    :  Color
	var strength :  float
	var p        := 3  ## phases amount
	var a        := .8 if type == "sun" else 5.2  ## fog color strength modifier


	# phase 1:
	color     = color_table[type]["disc"][1]
	strength  = color_table[type]["bg"][1]
	tween.tween_property(obj, "light_color", color, length /p *1.5)
	tween.parallel().tween_property(env_, "ambient_light_color", color, length /p *1.5)
	tween.parallel().tween_property(env_, "ambient_light_energy", strength *.6 *a, length /p *1.5)
	tween.parallel().tween_property(env_, "background_energy", strength, length /p *1.5)
	tween.parallel().tween_property(env_, "fog_color", color *strength *a, length /p *1.5)


	# phase 2:
	color  = color_table[type]["disc"][2]
	strength  = color_table[type]["bg"][2]
	tween.tween_property(obj, "light_color", color, length /p)
	tween.parallel().tween_property(env_, "ambient_light_color", color, length /p)
	tween.parallel().tween_property(env_, "ambient_light_energy", strength *.6 *a, length /p)
	tween.parallel().tween_property(env_, "background_energy", strength, length /p)
	tween.parallel().tween_property(env_, "fog_color", color *strength *a, length /p)


	# phase 3:
	color  = color_table[type]["disc"][0]
	strength  = color_table[type]["bg"][0]
	tween.tween_property(obj, "light_color", color, length /p *.5)
	tween.parallel().tween_property(env_, "ambient_light_color", color, length /p * .5)
	tween.parallel().tween_property(env_, "ambient_light_energy", strength *.6 *a, length /p*.5)
	tween.parallel().tween_property(env_, "background_energy", strength, length /p *.5)
	tween.parallel().tween_property(env_, "fog_color", color *strength *a, length /p *.5)


	# cycle end:
	tween.tween_property(obj, "light_color", Color(0,0,0), 1.4)
