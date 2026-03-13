extends Area2D

@export var target_scene: String = ""
@export var spawn_id: String = "default"
@export var is_enabled: bool = true

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node) -> void:
	if not is_enabled:
		return
	if body.is_in_group("player"):
		is_enabled = false
		print("HEADING TO: ")
		print(target_scene)
		TransitionManager.transition_to_spawn(target_scene, spawn_id)
