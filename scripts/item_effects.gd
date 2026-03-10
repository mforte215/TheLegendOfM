extends Node

func _ready() -> void:
	InventoryManager.item_used.connect(_on_item_used)

func _on_item_used(item: ItemData) -> void:
	
	match item.use_effect:
		"heal":
			_heal(item.effect_value)
		"heal_full":
			_heal(999)
		_:
			print("No effect defined for: ", item.use_effect)

func _heal(amount: int) -> void:
	Player.stats.current_health = min(
		Player.stats.current_health + amount,
		Player.stats.max_health
	)
	HUD.update_hearts()
	print("Healed for ", amount, ". Health: ", Player.stats.current_health)
