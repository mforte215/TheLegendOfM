extends Area2D

@export var speaker_name: String = ""
@export var dialogue_lines: Array = []

var player_nearby: bool = false

func _ready() -> void:
	collision_layer = 8  # triggers
	collision_mask = 2   # player	
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		player_nearby = true

func _on_body_exited(body: Node) -> void:
	if body.is_in_group("player"):
		player_nearby = false

func _input(event: InputEvent) -> void:
	if not player_nearby:
		return
	if DialogueBox.is_open:
		return
	if Input.is_action_just_pressed("interact"):
		DialogueBox.start(dialogue_lines, speaker_name)
