extends Area2D

@export var target_scene: String = "res://scenes/world/room_2.tscn"
@export var is_enabled: bool = true

func _ready() -> void:
	collision_layer = 8  # triggers
	collision_mask = 2   # player
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node) -> void:
	if not is_enabled:
		return
	if body.is_in_group("player"):
		is_enabled = false  # prevent double trigger
		TransitionManager.transition_to(target_scene)
