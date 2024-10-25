extends Camera


var map_data : Array
var vis_data : Dictionary


var def_zoom_speed := 30.0
var def_move_speed := 2.0

var min_h  :=  14.0
var max_h  :=  40.0
var min_a  := -36.0
var max_a  := -80.0
var min_f  :=  52.0
var max_f  :=  96.0
var min_d  :=  0.08
var max_d  :=  0.00
var min_sd :=  50
var max_sd :=  100


var curr_hex_index := 0
var prev_hex_index := 0
var curr_multimesh :  MultiMesh
var prev_multimesh :  MultiMesh

var hex_radius      = 2


##  Holders:
var xx             := 0.0
var move_speed_add := 0.0
var zoom_speed     := 0.0
var move_vector    := Vector3()
var target_tilt    := 0.0
var target_fov     := 0.0
var target_dof     := 0.0
var target_sd      := 0.0
var time_passed    := 0.0
var frame_count    := 0






func _ready() -> void:
	cam_mod()






func _process(dt: float) -> void:
	time_passed += dt

	#  Zoom:
	if zoom_speed != 0:
		global_transform.origin.y  = clamp(global_transform.origin.y + zoom_speed *dt,min_h,max_h)
		zoom_speed                 = lerp(zoom_speed, 0.0, .16)
		cam_mod()

	#  Move:
	if move_vector != Vector3():
		var vector  = transform.basis.x * move_vector.x + transform.basis.z * move_vector.z
		vector.y    = 0
		global_transform.origin += vector.normalized() * move_vector.length() * dt

	#  Tilt:
	if rotation_degrees.x != target_tilt:
		rotation_degrees.x = lerp(rotation_degrees.x, target_tilt, 0.06)

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


	if time_passed > .1:
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
	var mouse_pos = get_viewport().get_mouse_position()
	var from = project_ray_origin(mouse_pos + Vector2(-.25, +.5))
	var to = from + project_ray_normal(mouse_pos) * 100
	var hit_position = intersect_ray_with_plane(from, to)
	var err  := false

	if hit_position:
		var coord = world_to_hex(hit_position)

		if coord.x < 0 or coord.x > map_data[0].size()-1: err = true
		if coord.y < 0 or coord.y > map_data[1].size()-1: err = true

		if not err:
			var hex_type    = map_data[coord.x][coord.y]["type"]
			curr_hex_index  = map_data[coord.x][coord.y]["id"]
			curr_multimesh  = vis_data[hex_type].multimesh

			if curr_hex_index != prev_hex_index or curr_multimesh != prev_multimesh:
				curr_multimesh.set_instance_color(curr_hex_index, Color(.4, .6, 2))
				prev_multimesh.set_instance_color(prev_hex_index, Color(1,1,1))
				prev_hex_index  = curr_hex_index
				prev_multimesh  = curr_multimesh






func intersect_ray_with_plane(from, to):
	var plane = Plane(Vector3(0, 1, 0), 0)
	var hit_position = plane.intersects_segment(from, to)

	if hit_position != null:
		if plane.has_point(hit_position):
			return hit_position
	return null






func world_to_hex(pos: Vector3) -> Vector2:
	var q = pos.x / (hex_radius * 3 * .5)
	var r = (pos.z - (q * hex_radius * sqrt(3) * .5)) / (hex_radius * sqrt(3))

	var rounded_x = round(q)
	var rounded_y = round(r)

	return Vector2(rounded_y, rounded_x)





func cam_mod(move := 0.0) -> void:
	var ratio      := (global_transform.origin.y - min_h) / (max_h - min_h)
	zoom_speed      = clamp(zoom_speed + move, -def_zoom_speed, def_zoom_speed)
	move_speed_add  = def_move_speed * (1 + ratio * 32)

	target_tilt  = lerp(min_a,  max_a,  ratio)
	target_fov   = lerp(min_f,  max_f,  ratio)
	target_dof   = lerp(min_d,  max_d,  ratio)
	target_sd    = lerp(min_sd, max_sd, ratio)






func reload_map_data() -> void:
	map_data        = get_parent().map_data
	vis_data        = get_parent().visual_data
	prev_multimesh  = vis_data["flat01"].multimesh
