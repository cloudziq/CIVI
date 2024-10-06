#
#extends Camera
#
#
#
#
#var zoom_speed    := 10.0
#var move_speed    := 12.0
#
#var zoom_speed_iu := 0
#var move_speed_iu := Vector3()
#
#
#
#
#
#
#func _input(event) -> void:
#	if event is InputEventMouseButton:
#		if event.is_action_pressed("zoom+"):
#			zoom_speed_iu += zoom_speed
#		elif event.is_action_pressed("zoom-"):
#			zoom_speed_iu -= zoom_speed
#
#
#	if Input.is_action_pressed("move_L"):
#		move_speed_iu.x = -move_speed
#	elif Input.is_action_pressed("move_R"):
#		move_speed_iu.x =  move_speed
#	else:
#		move_speed_iu.x = 0
#
#	if Input.is_action_pressed("move_U"):
#		move_speed_iu.z = -move_speed
#	elif Input.is_action_pressed("move_D"):
#		move_speed_iu.z =  move_speed
#	else:
#		move_speed_iu.z = 0
#
#
#
#
#
#
#func _process(delta) -> void:
#	if zoom_speed_iu != 0:
#		translation += transform.basis.z * zoom_speed * delta
#		zoom_speed_iu = lerp(zoom_speed_iu, 0.0, 0.08)
#
#
#	if move_speed_iu != Vector3():
#		translation += transform.basis.x * move_speed_iu.x * delta
#		translation += transform.basis.z * move_speed_iu.z * delta
#


extends Camera



var h_move        :  Vector3

var zoom_speed    := 10.0
var move_speed    := 12.0

var zoom_speed_iu := 0
var move_speed_iu := Vector3()






func _input(event) -> void:
	if event is InputEventMouseButton:
		if event.is_action_pressed("zoom+"):
			zoom_speed_iu -= zoom_speed
		elif event.is_action_pressed("zoom-"):
			zoom_speed_iu += zoom_speed

	if Input.is_action_pressed("move_L"):
		move_speed_iu.x = -move_speed
	elif Input.is_action_pressed("move_R"):
		move_speed_iu.x = move_speed
	else:
		move_speed_iu.x = 0

	if Input.is_action_pressed("move_U"):
		move_speed_iu.z = -move_speed
	elif Input.is_action_pressed("move_D"):
		move_speed_iu.z = move_speed
	else:
		move_speed_iu.z = 0






func _process(delta) -> void:
	if zoom_speed_iu != 0:
		translation += transform.basis.z * zoom_speed_iu * delta
		zoom_speed_iu = lerp(zoom_speed_iu, 0.0, 0.08)

	if move_speed_iu != Vector3():
		h_move = transform.basis.x * move_speed_iu.x + transform.basis.z * move_speed_iu.z
		h_move.y = 0
		translation += h_move * delta
