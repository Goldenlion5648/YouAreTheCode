extends Camera2D

var mouse = Vector2()

func _input(event):
	if event is InputEventMouse:
		mouse = event.position
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			get_selection()

func get_selection():
	var worldspace = get_world_2d().direct_space_state
	var start = self.proj
	var end = project_position(mouse, 1000)
	var result = worldspace.intersect_ray(PhysicsRayQueryParameters3D.create(start, end))
