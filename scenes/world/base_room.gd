extends Node2D

var player_instance: CharacterBody2D

func _ready() -> void:
	y_sort_enabled = true
	
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
		var map_size := Vector2.ZERO
		for child in get_children():
			if child is TileMapLayer:
				var used: Rect2i = child.get_used_rect()
				var tile_size: Vector2i = child.tile_set.tile_size if child.tile_set else Vector2i(48, 48)
				var size := Vector2(used.end.x * tile_size.x, used.end.y * tile_size.y)
				if size.x > map_size.x:
					map_size = size
		
		if map_size == Vector2.ZERO:
			map_size = Vector2(960, 540)
		
		var pos := spawn_point.global_position
		var margin := 100.0
		
		if pos.y > map_size.y - margin:
			face_dir = Vector2.UP
		elif pos.y < margin:
			face_dir = Vector2.DOWN
		elif pos.x < margin:
			face_dir = Vector2.RIGHT
		elif pos.x > map_size.x - margin:
			face_dir = Vector2.LEFT
	
	# Instance the player into this scene
	player_instance = PlayerData.player_scene.instantiate()
	add_child(player_instance)
	player_instance.place_at(spawn_point.global_position, face_dir)
	player_instance.get_node("Camera2D").enabled = true
	
	HUD.show()
	
	_room_ready()

func _room_ready() -> void:
	pass
