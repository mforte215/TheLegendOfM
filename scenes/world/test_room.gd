extends Node2D

func _ready() -> void:
	Player.place_at($PlayerSpawn.global_position)
	Player.show()
	Player.enable_camera()
	HUD.show()

	var potion = load("res://resources/health_potion_min.tres")
	InventoryManager.add_item(potion, 3)
	print("Item id: '", potion.id, "'")
	print("Potion count: ", InventoryManager.get_item_count(potion.id))
	print("Slot 0: ", InventoryManager.get_slot(0))
