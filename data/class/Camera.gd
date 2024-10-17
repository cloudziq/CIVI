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

var immediate_geometry : ImmediateGeometry


var xx    : float






func _ready() -> void:
	immediate_geometry  = ImmediateGeometry.new()
	add_child(immediate_geometry)
	cam_mod()





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

	update_selected_hex()






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






func update_selected_hex() -> void:
	var viewport_size = get_viewport().size
	var center_screen = viewport_size / 2  # Środek ekranu

	# Rzutowanie promienia względem kamery ze środka ekranu w kierunku kursora
	var from = project_ray_origin(center_screen)  # Start promienia w środku ekranu
	var to = from + project_ray_normal(center_screen) * 100  # Kierunek promienia

	# Rysowanie linii debugowej
	draw_debug_line(from, to)

	# Sprawdzanie przecięcia promienia z obiektami w świecie
	var space_state = get_world().direct_space_state
	var result = space_state.intersect_ray(from, to)

	if result:
		var hit_pos = result.position  # Pozycja przecięcia promienia z obiektem
		var hex_coords = world_to_hex(hit_pos)  # Zamiana pozycji na współrzędne heksagonalne
		selected_hex = hex_coords
#		print("Heks na współrzędnych: ", hex_coords)
	else:
		selected_hex = null
#		print("Kursor nie jest nad żadnym heksem.")

func draw_debug_line(from, to) -> void:
	immediate_geometry.clear()
	immediate_geometry.begin(Mesh.PRIMITIVE_LINES, null)
	immediate_geometry.set_color(Color(1, 0, 0))  # Czerwony kolor
	immediate_geometry.add_vertex(from)  # Start linii w pozycji kamery
	immediate_geometry.add_vertex(to)    # Koniec linii w kierunku kursora
	immediate_geometry.end()

# Funkcja przeliczająca współrzędne świata na współrzędne heksagonalne
func world_to_hex(world_pos: Vector3) -> Vector3:
	var q = (world_pos.x * sqrt(3)/3 - world_pos.z / 3) / hex_radius
	var r = world_pos.z * 2/3 / hex_radius
	return cube_round(q, r)

# Zaokrąglanie współrzędnych heksagonalnych do najbliższego heksa
func cube_round(q, r) -> Vector3:
	var x = q
	var z = r
	var y = -x - z

	var rx = round(x)
	var ry = round(y)
	var rz = round(z)

	var x_diff = abs(rx - x)
	var y_diff = abs(ry - y)
	var z_diff = abs(rz - z)

	if x_diff > y_diff and x_diff > z_diff:
		rx = -ry - rz
	elif y_diff > z_diff:
		ry = -rx - rz
	else:
		rz = -rx - ry

	return Vector3(rx, ry, rz)
