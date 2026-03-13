extends Node2D

func _ready() -> void:
	print("Base room ready, spawn_id: ", TransitionManager.next_spawn_id)
	var spawn_id := TransitionManager.next_spawn_id
	var spawn_point: Marker2D = null
	
	for child in get_children():
		if child is Marker2D and child.name == "Spawn_" + spawn_id:
			spawn_point = child
			break
	
	if spawn_point == null:
		spawn_point = $Spawn_default
	
	var face_dir := Vector2.DOWN
	if "from_" in spawn_id:
		if spawn_point.global_position.y > 300:
			face_dir = Vector2.UP
		elif spawn_point.global_position.y < 100:
			face_dir = Vector2.DOWN
		elif spawn_point.global_position.x < 100:
			face_dir = Vector2.RIGHT
		elif spawn_point.global_position.x > 800:
			face_dir = Vector2.LEFT
	
	Player.place_at(spawn_point.global_position, face_dir)
	Player.show()
	Player.enable_camera()
	HUD.show()
	
	_room_ready()

func _room_ready() -> void:
	pass  # Override in individual rooms for room-specific setup
