extends Area2D

@export var item: ItemData

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node) -> void:
	if not body.is_in_group("player"):
		return
	
	if Player.stats.inventory.add_item(item):
		print("picked up: ", item.item_name)
		print("inventory size: ", Player.stats.inventory.items.size())
		for i in Player.stats.inventory.items:
			print("- ", i.item_name)
		queue_free()
	else:
		print("inventory full")
