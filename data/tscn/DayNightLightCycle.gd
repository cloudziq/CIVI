extends     Node
class_name  DayNightLightCycle


onready var sun    : DirectionalLight = $"../%Sun"
onready var moon   : DirectionalLight = $"../%Moon"
onready var env    : WorldEnvironment = $"../%Env"
onready var env_   : Environment      = env.environment
onready var t_env  : SceneTreeTween
onready var angle  : float            = $"../%Cam".rotation_degrees.y


## Main settings:
var day_length    := 18.0   ## in seconds
var night_length  := 14.0
var phases_amount := 3      ## phases amount (see param_table)

var sun_min_h  :=  0
var sun_max_h  := -36.0
var moon_min_h :=  0
var moon_max_h := -25.0
var rot_dir    := -1

onready var start_pos    :=  angle -90.0
onready var end_pos      :=  angle +start_pos +90
onready var bg_start_pos :=  start_pos +120.0

var moon_start_offset := (day_length -(night_length *.12)) -1 -day_length   *.02
var sun_start_offset  := (night_length -(day_length *.14)) -1 -night_length *.02

var sun_vis    := true
var moon_vis   := false



## Holders:
var sun_p      := 0.0
var moon_p     := 0.0
var bg_p       := 0.0
var sun_cycle  := 0.0
var moon_cycle := 0.0
var bg_cycle   := 0.0
var col_       : Color
var str_       : float
var sat_       : float
var phase_time : float


var param_table := {
	"day": {
		"color": [
			Color(.62, .56, .44),
			Color(.58, .54, .48),
			Color(.24, .12, .16)
		],
		"bg_strength": [.96, 1.1, .8],
		"saturation":  [1.3, 1.6, 1.1]
	},
	"night": {
		"color": [
			Color(.14, .16, .24),
			Color(.16, .24, .32),
			Color(.12, .18, .26)
		],
		"bg_strength": [.5, .1, 1.1],
		"saturation":  [.9, .82, .92]
	}
}







func _ready() -> void:
	moon.visible  = false





func _process(dt: float) -> void:
		var bg_angle := 0.0

		bg_cycle += dt
		if bg_cycle <sun_start_offset +moon_start_offset:
			var bg_end_pos := bg_start_pos +360
			bg_p      = bg_cycle / (sun_start_offset +moon_start_offset)
			bg_angle  = lerp(bg_start_pos, bg_end_pos, bg_p)
			env_.background_sky_rotation_degrees.y  = bg_angle
		else:
			bg_cycle  = 0


		if sun_vis:
			if sun_cycle == 0: aura_init("day")
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
			if moon_cycle == 0: aura_init("night")
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






func aura_init(type: String) -> void:
	phase_time  = day_length /phases_amount if type == "day" else night_length /phases_amount
	phase_run(type, phase_time)






func phase_run(type:String, time:float, phase:=0) -> void:
	var obj   := sun if type == "day" else moon
	var a     := 1.2 if type == "day" else 1.8  ## fog & ambient strength modifier

	if phase == 0:
		obj.visible  = true
		t_env  = get_tree().create_tween().set_parallel(false)

	if phase < phases_amount:
		col_  = param_table[type]["color"][phase]
		str_  = param_table[type]["bg_strength"][phase]
		sat_  = param_table[type]["saturation"][phase]

		t_env.tween_property(obj, "light_color", col_, time)
		t_env.parallel().tween_property(env_, "ambient_light_color", col_ *1.1, time)
		t_env.parallel().tween_property(env_, "ambient_light_energy", a *2.2, time)
		t_env.parallel().tween_property(env_, "fog_color", col_ *str_ *a, time)
		t_env.parallel().tween_property(env_, "background_energy", str_, time)
		t_env.parallel().tween_property(env_, "adjustment_saturation", sat_, time)

		phase_run(type, time, phase +1)
	else:
		t_env.tween_property(obj, "light_color", Color(0,0,0), 1.25)
		t_env.tween_property(obj, "visible", false, 0)
