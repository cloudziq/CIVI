extends Camera


var map_data :  Array
var raycast  := RayCast.new()




onready var highlight := $"../%Highlight"

var def_zoom_speed := 6.2
var def_move_speed := 1.8

var min_h  :=  10.0
var max_h  :=  22.0
var min_a  := -32.0
var max_a  := -62.0
var min_f  :=  52.0
var max_f  :=  84.0
var min_d  :=  0.08
var max_d  :=  0.04
var min_sd :=  50
var max_sd :=  100

var hex_radius     := 2


##  Holders:
var hex            :  StaticBody
var hex_pos        :  Vector3
var xx             := 0.0
var move_speed_add := 0.0
var zoom_speed     := 0.0
var move_vector    := Vector3()
var highlight_targ := Vector3()
var target_tilt    := 0.0
var target_fov     := 0.0
var target_dof     := 0.0
var target_sd      := 0.0
var time_passed    := 0.0
var frame_count    := 0






func _ready() -> void:
	global_transform.origin.y  = min_h + (max_h - min_h) *.5
	rotation_degrees.x         = min_a + (max_a - min_a) *.5

	raycast.enabled  = true
	add_child(raycast)
	cam_mod()






func _process(dt: float) -> void:
	time_passed += dt

	#  Zoom:
	if zoom_speed != 0:
		global_transform.origin.y  = clamp(global_transform.origin.y +zoom_speed *dt, min_h,max_h)
		zoom_speed                 = lerp(zoom_speed, 0.0, .22)
		cam_mod()

	#  Move:
	if move_vector != Vector3():
		var vector  = transform.basis.x *move_vector.x +transform.basis.z *move_vector.z
		vector.y    = 0
		global_transform.origin += vector.normalized() *move_vector.length() *dt

	#  Tilt:
	if rotation_degrees.x != target_tilt:
		rotation_degrees.x = lerp(rotation_degrees.x, target_tilt, .1)

	#  FOV:
	if fov != target_fov:
		fov = lerp(fov, target_fov, 0.08)

	#  DOF:
	xx  = $"%Env".environment.dof_blur_far_amount
	if xx != target_dof:
		$"%Env".environment.dof_blur_far_amount = lerp(xx, target_dof, 0.01)

	#  Shadow Distance:
	xx  = $"%Sun".directional_shadow_max_distance
	if xx != target_sd:
		$"%Sun".directional_shadow_max_distance = lerp(xx, target_sd, .6)

	#  Highlight:
	if highlight.position != highlight_targ:
		highlight.position  = lerp(highlight.position, highlight_targ, .42)


	if time_passed > .01:
		time_passed = 0
		get_hex_at_mouse()






func _input(event) -> void:
	if Input.is_action_pressed("move_L"):
		move_vector.x = -def_move_speed - move_speed_add
	elif Input.is_action_pressed("move_R"):
		move_vector.x = def_move_speed + move_speed_add
	else:
		move_vector.x = 0

	if Input.is_action_pressed("move_U"):
		move_vector.z = -def_move_speed - move_speed_add
	elif Input.is_action_pressed("move_D"):
		move_vector.z = def_move_speed + move_speed_add
	else:
		move_vector.z = 0

	#  Mouse zoom:
	if event is InputEventMouseButton:
		if event.is_action_pressed("zoom+"):
			cam_mod(-def_zoom_speed)
		elif event.is_action_pressed("zoom-"):
			cam_mod(def_zoom_speed)






func get_hex_at_mouse():
	var mouse_pos    = get_viewport().get_mouse_position()
	var origin       = project_ray_origin(mouse_pos) + Vector3(0,.4,0)
	var direction    = project_ray_normal(mouse_pos)
	var space_state  = get_world().direct_space_state
	var ray_test     = space_state.intersect_ray(origin, origin + direction * 82)

	if ray_test:
		hex  = ray_test.collider
		hex_pos  = hex.position
		highlight_targ  = hex_pos -Vector3(0, -.12, 0)






func world_to_hex(pos: Vector3) -> Vector2:
	var q = pos.x / (hex_radius *3 *.5)
	var r = (pos.z - (q *hex_radius *sqrt(3) *.5)) / (hex_radius *sqrt(3))

	var rounded_x = round(q)
	var rounded_y = round(r)

	return Vector2(rounded_x, rounded_y)






func cam_mod(move  := 0.0) -> void:
	var ratio      := (global_transform.origin.y -min_h) /(max_h -min_h)
	zoom_speed      = clamp(zoom_speed +move, -def_zoom_speed, def_zoom_speed)
	move_speed_add  = def_move_speed * (1 + ratio * 32)

	target_tilt  = lerp(min_a,  max_a,  ratio)
	target_fov   = lerp(min_f,  max_f,  ratio)
	target_dof   = lerp(min_d,  max_d,  ratio)
	target_sd    = lerp(min_sd, max_sd, ratio)





#func reload_map_data() -> void:
#	map_data        = get_parent().map_data
#	vis_data        = get_parent().visual_data
#	prev_multimesh  = vis_data["flat01"].multimesh
