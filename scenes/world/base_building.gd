extends StaticBody2D

@export var target_scene: String = ""
@export var spawn_id: String = "default"
@export_enum("up", "down", "left", "right") var door_direction: String = "up"

var door_opened := false

func _ready() -> void:
	$DoorArea.body_entered.connect(_on_body_entered)
	if $DoorSprite.sprite_frames != null:
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
	if not player:
		return
	
	player.set_physics_process(false)
	player.velocity = Vector2.ZERO
	
	if $DoorSprite.sprite_frames != null:
		$DoorSprite.play("opening")
		await $DoorSprite.animation_finished
		$DoorSprite.play("open")
	
	# Walk direction based on export
	var walk_offset := Vector2.ZERO
	match door_direction:
		"up":
			walk_offset = Vector2(0, -40)
		"down":
			walk_offset = Vector2(0, 40)
		"left":
			walk_offset = Vector2(-40, 0)
		"right":
			walk_offset = Vector2(40, 0)
	
	var walk_target: Vector2 = player.global_position + walk_offset
	player.get_node("AnimatedSprite2D").play("walk_" + door_direction)
	
	var tween := create_tween()
	tween.tween_property(player, "global_position", walk_target, 0.6)
	await tween.finished
	
	player.visible = false
	
	if target_scene != "":
		TransitionManager.transition_to_spawn(target_scene, spawn_id)
