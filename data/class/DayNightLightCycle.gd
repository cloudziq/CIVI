extends     Node
class_name  DayNightLightCycle


var day_length   := 16    ## in sec
var night_length := 12

var sun_min_h    :=   0.0
var sun_max_h    := -20.0
var moon_min_h   :=  -0.0
var moon_max_h   := -60.0

var start_pos    := 220.0
var end_pos      :=  20.0
var rotation_dir :=     1

var sun_color_day       := Color(1, 1, .8)
var sun_color_evening   := Color(1, .6, .2)
var moon_color_night    := Color(.3, .4, .8)
var moon_color_near_day := Color(.9, .6, .8)

onready var sun  := $"../%Sun"
onready var moon := $"../%Moon"
onready var env  := $"../%Env"

## holders:
var cycle_time     := 0.0    ## Aktualny czas w cyklu
var cycle_progress := 0.0    ## Cykl (0 do 1)






func _process(delta) -> void:
	cycle_time += delta
	cycle_progress = cycle_time / (day_length + night_length)

	if cycle_progress <= .75:
		var sun_progress := cycle_progress / .75
		update_sun(sun_progress)
	elif cycle_progress <= 1.0:
		var moon_progress := (cycle_progress - .75) / .25
		update_moon(moon_progress)

	if cycle_time >= (day_length + night_length):
		cycle_time = 0.0






func update_sun(progress):
	var sun_color     : Color
	var current_dist = lerp(start_pos, end_pos, progress) * rotation_dir

	var angle_x : float = sun_min_h + (sun_max_h - sun_min_h) * sin(progress * PI)
	sun.rotation_degrees = Vector3(angle_x, current_dist, 0)

	if progress <= .33:
		moon.light_energy = 0
		sun_color = sun_color_evening.linear_interpolate(sun_color_day, progress / 0.33)
		sun.light_energy = lerp(.4, .8, progress / .33)
		env.environment.ambient_light_energy = lerp(.3, .8, progress / .33)
	elif progress <= .66:
		sun_color = sun_color_day
		sun.light_energy = .8
		env.environment.ambient_light_energy = .8
	else:
		sun_color = sun_color_day.linear_interpolate(sun_color_evening, (progress - .66) / .33)
		sun.light_energy = lerp(0.8, 0, (progress - .66) / .33)
		env.environment.ambient_light_energy = lerp(0.8, 0.4, (progress - .66) / .33)

	sun.light_color = sun_color
	env.environment.ambient_light_color = sun_color





func update_moon(progress) -> void:
	var moon_color : Color
	var current_dist = lerp(start_pos, end_pos, progress) * rotation_dir

	var angle_x : float = moon_min_h + (moon_max_h - moon_min_h) * sin(progress * PI)
	moon.rotation_degrees = Vector3(angle_x, current_dist, 0)

	if progress <= .33:
		moon_color = moon_color_near_day.linear_interpolate(moon_color_night, progress / 0.33)
		moon.light_energy = lerp(0.1, 0.25, progress / 0.33)
		env.environment.ambient_light_energy = lerp(.4, .1, progress / .33)
	elif progress <= .66:
		moon_color = moon_color_night
		moon.light_energy = 0.25
		env.environment.ambient_light_energy = 0.1
	else:
		moon_color = moon_color_night.linear_interpolate(moon_color_near_day, (progress - 0.66) / 0.33)
		moon.light_energy = lerp(0.25, 0.0, (progress - 0.66) / 0.33)
		env.environment.ambient_light_energy = lerp(0.1, 0.3, (progress - .66) / .33)

	moon.light_color = moon_color
	env.environment.ambient_light_color = moon_color
