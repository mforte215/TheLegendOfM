extends Area2D

@export var value: int = 1

@onready var sprite := $Sprite2D

func _ready() -> void:
	collision_layer = 8
	collision_mask = 2
	monitoring = false
	
	await get_tree().create_timer(0.2).timeout
	monitoring = true
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node) -> void:
	if not body.is_in_group("player"):
		return
	PlayerData.add_coins(value)
	print("Picked up ", value, " coin(s). Total: ", PlayerData.coins)
	queue_free()
