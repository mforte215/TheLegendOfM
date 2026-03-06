extends Area2D

@export var item: ItemData

@onready var sprite := $Sprite2D

func _ready() -> void:
	collision_layer = 8   # layer 4 in bitmask
	collision_mask = 2    # layer 2 in bitmask
	body_entered.connect(_on_body_entered)
	if item and item.icon:
		sprite.texture = item.icon

func _on_body_entered(body: Node) -> void:
	if not body.is_in_group("player"):
		return
	
	if Player.stats.inventory.add_item(item):
		print("picked up: ", item.item_name)
		print("inventory size: ", Player.stats.inventory.items.size())
		for i in Player.stats.inventory.items:
			print("- ", i.item_name)
		Player.stats.inventory.equip_item(item)
		HUD.update_item_slot()
		queue_free()
	else:
		print("inventory full")
