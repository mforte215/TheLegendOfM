extends Node

const SAVE_PATH := "user://savegame.json"

func save_game() -> void:
	var save_data := {
		"player_stats": {
			"current_health": Player.stats.current_health,
			"max_health": Player.stats.max_health,
			"attack": Player.stats.attack,
			"defense": Player.stats.defense,
			"speed": Player.stats.speed,
			"level": Player.stats.level,
			"experience": Player.stats.experience
		},
		"inventory": {
			"slots": [],
			"equipped": {}
		}
	}
	
	# Save inventory slots
	for i in InventoryManager.MAX_SLOTS:
		var slot = InventoryManager.get_slot(i)
		if slot != null:
			save_data["inventory"]["slots"].append({
				"index": i,
				"item_path": slot["item"].resource_path,
				"quantity": slot["quantity"]
			})
	
	# Save equipped items
	for slot_name in InventoryManager.equipped:
		var item: ItemData = InventoryManager.equipped[slot_name]
		save_data["inventory"]["equipped"][slot_name] = item.resource_path
	
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	file.store_string(JSON.stringify(save_data))
	file.close()
	print("game saved")

func load_game() -> bool:
	if not FileAccess.file_exists(SAVE_PATH):
		return false
	
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	var json_string := file.get_as_text()
	file.close()
	
	var json := JSON.new()
	var error := json.parse(json_string)
	if error != OK:
		print("save file corrupted")
		return false
	
	var save_data: Dictionary = json.get_data()
	
	# Restore stats
	var stats: Dictionary = save_data["player_stats"]
	Player.stats.current_health = stats["current_health"]
	Player.stats.max_health = stats["max_health"]
	Player.stats.attack = stats["attack"]
	Player.stats.defense = stats["defense"]
	Player.stats.speed = stats["speed"]
	Player.stats.level = stats["level"]
	Player.stats.experience = stats["experience"]
	
	# Clear inventory
	for i in InventoryManager.MAX_SLOTS:
		InventoryManager.slots[i] = null
	InventoryManager.equipped.clear()
	
	# Restore inventory slots
	for slot_data in save_data["inventory"]["slots"]:
		var item := load(slot_data["item_path"]) as ItemData
		if item:
			var index: int = slot_data["index"]
			InventoryManager.slots[index] = {
				"item": item,
				"quantity": slot_data["quantity"]
			}
	
	# Restore equipped items
	for slot_name in save_data["inventory"]["equipped"]:
		var item := load(save_data["inventory"]["equipped"][slot_name]) as ItemData
		if item:
			InventoryManager.equipped[slot_name] = item
	
	InventoryManager.inventory_changed.emit()
	HUD.update_hearts()
	print("game loaded")
	return true

func has_save() -> bool:
	return FileAccess.file_exists(SAVE_PATH)
