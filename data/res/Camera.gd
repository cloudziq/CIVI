extends Camera




var move           :  Vector3
var move_speed_add := 0.0
var zoom_speed     := 0.0
var move_speed     := Vector3()
var target_angle   := 0.0

var def_zoom_speed := 26.0
var def_move_speed := 12.0
var def_angle      :=  -60

var min_h :=  12
var max_h :=  42
var min_a := -80
var max_a := -40






func _ready() -> void:
	cam_mod()






func _process(delta) -> void:
	#  Zooming:
	if zoom_speed != 0:
		global_translation.y = clamp(global_translation.y + zoom_speed * delta, min_h, max_h)
		zoom_speed = lerp(zoom_speed, 0.0, .2)

	#  Moving:
	if move_speed != Vector3():
		var vector = transform.basis.x * move_speed.x + transform.basis.z * move_speed.z
		vector.y = 0
		global_translation += vector.normalized() * move_speed.length() * delta

	#  Tilting:
	if rotation_degrees.x != target_angle:
		rotation_degrees.x = lerp(rotation_degrees.x, target_angle, 0.1)






func _input(event) -> void:
	if Input.is_action_pressed("move_L"):
		move_speed.x = -def_move_speed - move_speed_add
	elif Input.is_action_pressed("move_R"):
		move_speed.x = def_move_speed + move_speed_add
	else:
		move_speed.x = 0

	if Input.is_action_pressed("move_U"):
		move_speed.z = -def_move_speed - move_speed_add
	elif Input.is_action_pressed("move_D"):
		move_speed.z = def_move_speed + move_speed_add
	else:
		move_speed.z = 0

	#  mouse zoom:
	if event is InputEventMouseButton:
		if event.is_action_pressed("zoom+"):
			cam_mod(-def_zoom_speed)
		elif event.is_action_pressed("zoom-"):
			cam_mod(def_zoom_speed)






func cam_mod(move_ := 0.0) -> void:
	zoom_speed += move_
	zoom_speed = clamp(zoom_speed, -def_zoom_speed, def_zoom_speed)
	move_speed_add = def_move_speed * (1 + (global_translation.y - min_h) / (max_h - min_h) * 6)

	target_angle = lerp(min_a, max_a, (global_translation.y - min_h) / (max_h - min_h))
