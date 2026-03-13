extends CanvasLayer

var is_transitioning := false
var next_spawn_id: String = "default"

func fade_to_black() -> void:
	var tween := create_tween()
	tween.tween_property($Overlay, "color:a", 1.0, 0.4)
	await tween.finished

func fade_to_clear() -> void:
	var tween := create_tween()
	tween.tween_property($Overlay, "color:a", 0.0, 0.4)
	await tween.finished

func transition_to(scene_path: String) -> void:
	if is_transitioning:
		return
	is_transitioning = true
	next_spawn_id = "default"
	await fade_to_black()
	get_tree().change_scene_to_file(scene_path)
	await fade_to_clear()
	is_transitioning = false

func transition_to_spawn(scene_path: String, spawn_id: String) -> void:
	if is_transitioning:
		return
	is_transitioning = true
	next_spawn_id = spawn_id
	print("TransitionManager storing spawn_id: '", next_spawn_id, "'")
	await fade_to_black()
	get_tree().change_scene_to_file(scene_path)
	await fade_to_clear()
	is_transitioning = false
