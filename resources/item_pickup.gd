extends Area2D

@export var item: ItemData

@onready var sprite := $Sprite2D

func _ready() -> void:
	collision_layer = 8
	collision_mask = 2
	monitoring = false  # Disable detection at start
	if item and item.icon:
		sprite.texture = item.icon
		var tex_size: Vector2 = item.icon.get_size()
		var target_size: float = 24.0
		sprite.scale = Vector2(target_size / tex_size.x, target_size / tex_size.y)
	# Wait for scene to settle before enabling
	await get_tree().create_timer(0.2).timeout
	monitoring = true
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node) -> void:
	if not body.is_in_group("player"):
		return
	
	if InventoryManager.add_item(item):
		print("picked up: ", item.item_name)
		print("inventory size: ", InventoryManager.get_item_count(item.id))
		queue_free()
	else:
		print("inventory full")
