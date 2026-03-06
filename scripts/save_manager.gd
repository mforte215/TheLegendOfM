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
			"items": [],
			"equipped_item": ""
		}
	}
	
	# Save inventory items
	for item in Player.stats.inventory.items:
		save_data["inventory"]["items"].append(item.resource_path)
	
	# Save equipped item
	if Player.stats.inventory.equipped_item != null:
		save_data["inventory"]["equipped_item"] = Player.stats.inventory.equipped_item.resource_path
	
	# Write to file
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
	
# Restore inventory
	Player.stats.inventory.items.clear()
	Player.stats.inventory.equipped_item = null  # Add this
	for item_path in save_data["inventory"]["items"]:
		var item := load(item_path) as ItemData
		if item:
			Player.stats.inventory.items.append(item)

	# Restore equipped item
	var equipped_path: String = save_data["inventory"]["equipped_item"]
	if equipped_path != "":
		Player.stats.inventory.equipped_item = load(equipped_path) as ItemData
	
	HUD.update_hearts()
	HUD.update_item_slot()
	print("game loaded")
	return true

func has_save() -> bool:
	return FileAccess.file_exists(SAVE_PATH)
