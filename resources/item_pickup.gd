extends Area2D

@export var item: ItemData

@onready var sprite := $Sprite2D

func _ready() -> void:
	collision_layer = 8
	collision_mask = 2
	monitoring = false
	
	# Check if this pickup was already collected
	var pickup_id := _get_pickup_id()
	if pickup_id in InventoryManager.collected_pickups:
		queue_free()
		return
	
	if item and item.icon:
		sprite.texture = item.icon
		var tex_size: Vector2 = item.icon.get_size()
		var target_size: float = 48
		sprite.scale = Vector2(target_size / tex_size.x, target_size / tex_size.y)
	
	await get_tree().create_timer(0.2).timeout
	monitoring = true
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node) -> void:
	if not body.is_in_group("player"):
		return
	
	if InventoryManager.add_item(item):
		InventoryManager.collected_pickups.append(_get_pickup_id())
		print("picked up: ", item.item_name)
		print("inventory size: ", InventoryManager.get_item_count(item.id))
		queue_free()
	else:
		print("inventory full")

func _get_pickup_id() -> String:
	# Unique ID based on scene path + node path
	return get_tree().current_scene.scene_file_path + ":" + str(get_path())
