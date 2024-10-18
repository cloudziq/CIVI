extends Camera

var move_speed_add := 0.0
var zoom_speed     := 0.0
var move_vector    := Vector3()
var target_tilt    := 0.0
var target_fov     := 0.0
var target_dof     := 0.0
var target_sd      := 0.0

var def_zoom_speed := 25.0
var def_move_speed := 2.0

var min_h  :=  14.0
var max_h  :=  40.0
var min_a  := -36.0
var max_a  := -76.0
var min_f  :=  52.0
var max_f  :=  96.0
var min_d  :=  0.06
var max_d  :=  0.0
var min_sd :=  60
var max_sd :=  80

var hex_radius    = 2.0
var selected_hex  = null

#  cały multimesh:
var multimesh_instance_1 : MultiMeshInstance
var multimesh_instance_2 : MultiMeshInstance

# Zmienna na indeks wybranego hexa
var selected_hex_index    := -1
var selected_hex_instance :=  1

##  Holders:
var xx    : float






func _ready() -> void:
	cam_mod()
	multimesh_instance_1 = get_parent().terrain_data[0][1]
	multimesh_instance_2 = get_parent().terrain_data[1][1]






func _process(delta: float) -> void:
	#  Zoom:
	if zoom_speed != 0:
		global_transform.origin.y  = clamp(global_transform.origin.y+zoom_speed*delta,min_h,max_h)
		zoom_speed                 = lerp(zoom_speed, 0.0, .16)
		cam_mod()

	#  Move:
	if move_vector != Vector3():
		var vector  = transform.basis.x * move_vector.x + transform.basis.z * move_vector.z
		vector.y    = 0
		global_transform.origin += vector.normalized() * move_vector.length() * delta

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

	# Sprawdzenie hexa pod kursorem
	var new_hex_index_1 = get_hex_at_mouse(multimesh_instance_1)
	var new_hex_index_2 = get_hex_at_mouse(multimesh_instance_2)

	# Resetowanie koloru poprzedniego wybranego hexa
	if selected_hex_index != -1:
		if selected_hex_instance == 1:
			multimesh_instance_1.multimesh.set_instance_color(selected_hex_index, Color(1, 1, 1))
		elif selected_hex_instance == 2:
			multimesh_instance_2.multimesh.set_instance_color(selected_hex_index, Color(1, 1, 1))

	# Zmiana koloru nowego wybranego hexa
	if new_hex_index_1 != -1:
		multimesh_instance_1.multimesh.set_instance_color(new_hex_index_1, Color(.5, 1, .5))
		selected_hex_instance = 1
		selected_hex_index = new_hex_index_1
	elif new_hex_index_2 != -1:
		multimesh_instance_2.multimesh.set_instance_color(new_hex_index_2, Color(.5, 1, .5))
		selected_hex_instance = 2
		selected_hex_index = new_hex_index_2



func get_hex_at_mouse(multimesh_instance: MultiMeshInstance):
	var mouse_pos = get_viewport().get_mouse_position()
	var from = project_ray_origin(mouse_pos)
	var to = from + project_ray_normal(mouse_pos) * 100  # Promień w przestrzeni 3D

	var hit_position = intersect_ray_with_plane(from, to)

	if hit_position:
		var hex_coords = world_to_hex(hit_position)
		return get_hex_instance_index(hex_coords, multimesh_instance)

	return -1


# Oblicza pozycję promienia na płaszczyźnie
func intersect_ray_with_plane(from, to):
	var plane = Plane(Vector3(0, 1, 0), 0)  # Zakładając, że twoje heksy są na płaskiej powierzchni
	var hit_position = plane.intersects_segment(from, to)

	if hit_position != null:
		if plane.has_point(hit_position):
			return hit_position

	return null





func world_to_hex(pos: Vector3) -> Vector2:
	var q = pos.x / (hex_radius * 3 * .5)  # Uwzględnia szerokość heksa w osi X
	var r = (pos.z - (q * hex_radius * sqrt(3) * .5)) / (hex_radius * sqrt(3))  # Uwzględnia przesunięcie na osi Z

	# Zaokrąglamy współrzędne q i r
	var rounded_q = round(q)
	var rounded_r = round(r)

	return Vector2(rounded_q, rounded_r).rotated(33)




# Funkcja, która zwraca indeks instancji MultiMesh na podstawie pozycji hexa
func get_hex_instance_index(hex_pos: Vector2, multimesh_instance: MultiMeshInstance) -> int:
	for i in range(multimesh_instance.multimesh.instance_count):
		var instance_pos = multimesh_instance.multimesh.get_instance_transform(i).origin
		var hex_from_instance = world_to_hex(instance_pos)
		if hex_from_instance == hex_pos:
			return i
	return -1






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





func cam_mod(move := 0.0) -> void:
	var ratio      := (global_transform.origin.y - min_h) / (max_h - min_h)
	zoom_speed      = clamp(zoom_speed + move, -def_zoom_speed, def_zoom_speed)
	move_speed_add  = def_move_speed * (1 + ratio * 22)

	target_tilt  = lerp(min_a,  max_a,  ratio)
	target_fov   = lerp(min_f,  max_f,  ratio)
	target_dof   = lerp(min_d,  max_d,  ratio)
	target_sd    = lerp(min_sd, max_sd, ratio)


