extends     Node
class_name  DayNightLightCycle


onready var sun  := $"../%Sun"
onready var moon := $"../%Moon"
onready var env  := $"../%Env"


## Main settings:
var day_length   := 20.0    ## in seconds
var night_length := 16.0

var sun_min_h  :=   0.0    ## minimalna wysokość słońca (przy wschodzie i zachodzie)
var sun_max_h  := -40.0    ## maksymalna wysokość słońca (w południe)
var moon_min_h := -20.0    ## minimalna wysokość księżyca (przy zachodzie)
var moon_max_h := -60.0    ## maksymalna wysokość księżyca (noc)

var start_pos := 220.0     ## początkowa pozycja kątowa ciał niebieskich
var end_pos   := 20.0      ## końcowa pozycja kątowa ciał niebieskich
var rot_dir   := 1         ## kierunek obrotu

var sun_vis    := true
var moon_vis   := false


## Holders:
var sun_p      := 0.0
var moon_p     := 0.0
var sun_cycle  := 0.0
var moon_cycle := 0.0





func _process(delta: float) -> void:
	if sun_vis:
		if sun_cycle == 0: aura_control(1)
		sun_cycle += delta

		if sun_cycle < day_length:
			if sun_cycle > day_length - (day_length * .06) : moon_vis  = true
			sun_p  = sun_cycle / day_length

			var current_dist      = lerp(start_pos, end_pos, sun_p) * rot_dir
			var angle_x: float    = lerp(sun_min_h, sun_max_h, sin(sun_p * PI))
			sun.rotation_degrees  = Vector3(angle_x, current_dist, 0)
		else:
			sun_cycle  = 0    ;    sun_vis  = false

	if moon_vis:
		if moon_cycle == 0: aura_control(0)
		moon_cycle += delta
		if moon_cycle < night_length:
			if moon_cycle > night_length - (night_length * .1) : sun_vis  = true
			moon_p  = moon_cycle / night_length

			var current_dist      = lerp(start_pos, end_pos, moon_p) * rot_dir
			var angle_x: float    = lerp(moon_min_h, moon_max_h, sin(moon_p * PI))
			moon.rotation_degrees  = Vector3(angle_x, current_dist, 0)
		else:
			moon_cycle  = 0    ;    moon_vis  = false



var color_table  = [
	{"moon_color_0": Color(0, .02, .04),
	 "moon_color_1": Color(.14, .16, .28),
	 "moon_color_2": Color(.1, .12, .22)
	},
	{"sun_color_0": Color(.2, .12, .08),
	 "sun_color_1": Color(.82, .76, .68),
	 "sun_color_2": Color(.56, .42, .38)
	}
]





func aura_control(type:int) -> void:
	var obj     := sun if type == 1 else moon
	var string  := "sun" if type == 1 else "moon"
	var length  := day_length if type == 1 else night_length
	var tween   := get_tree().create_tween().set_parallel(false)
	var env_    :  Environment  = env.environment
	var color   :  Color
	var toffset := 3

	obj.light_color           = color_table[type][string+"_color_0"]
	env_.ambient_light_color  = color_table[type][string+"_color_0"]

	color  = color_table[type][string+"_color_1"]
	tween.tween_property(obj, "light_color", color, length / toffset * 1.5)
	tween.parallel().tween_property(env_, "ambient_light_color", color, length / toffset * 1.5)

	color  = color_table[type][string+"_color_2"]
	tween.tween_property(obj, "light_color", color, length / toffset)
	tween.parallel().tween_property(env_, "ambient_light_color", color, length / toffset)

	color  = color_table[type][string+"_color_0"]
	tween.tween_property(obj, "light_color", color, length / toffset * .5)
	tween.parallel().tween_property(env_, "ambient_light_color", color, length / toffset * .5)

	tween.tween_property(obj, "light_color", Color(0,0,0), 1)
	tween.parallel().tween_property(env_, "ambient_light_color",
		Color(0,0,0), length / toffset * .6)
