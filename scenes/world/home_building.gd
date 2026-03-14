extends StaticBody2D

@export var target_scene: String = ""
@export var spawn_id: String = "default"

var door_opened := false

func _ready() -> void:
	$DoorArea.body_entered.connect(_on_body_entered)
	$DoorSprite.play("closed")

func _on_body_entered(body: Node) -> void:
	if not body.is_in_group("player"):
		return
	if door_opened:
		return
	open_door()

func open_door() -> void:
	door_opened = true
	
	var player = get_tree().get_first_node_in_group("player")
	if player:
		player.set_physics_process(false)
		player.velocity = Vector2.ZERO
	
	$DoorSprite.play("opening")
	await $DoorSprite.animation_finished
	$DoorSprite.play("open")
	
	if target_scene != "":
		await get_tree().create_timer(0.3).timeout
		TransitionManager.transition_to_spawn(target_scene, spawn_id)
