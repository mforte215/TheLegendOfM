extends Node

const SAVE_PATH := "user://savegame.json"

func save_game() -> void:
	var save_data := {
		"player_stats": {
			"current_health": PlayerData.stats.current_health,
			"max_health": PlayerData.stats.max_health,
			"attack": PlayerData.stats.attack,
			"defense": PlayerData.stats.defense,
			"speed": PlayerData.stats.speed,
			"level": PlayerData.stats.level,
			"experience": PlayerData.stats.experience
		},
		"coins": PlayerData.coins,
		"inventory": {
			"slots": [],
			"equipped": {},
			"collected_pickups": InventoryManager.collected_pickups
		}
	}
	
	for i in InventoryManager.MAX_SLOTS:
		var slot = InventoryManager.get_slot(i)
		if slot != null:
			save_data["inventory"]["slots"].append({
				"index": i,
				"item_path": slot["item"].resource_path,
				"quantity": slot["quantity"]
			})
	
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
	
	var stats: Dictionary = save_data["player_stats"]
	PlayerData.stats.current_health = stats["current_health"]
	PlayerData.stats.max_health = stats["max_health"]
	PlayerData.stats.attack = stats["attack"]
	PlayerData.stats.defense = stats["defense"]
	PlayerData.stats.speed = stats["speed"]
	PlayerData.stats.level = stats["level"]
	PlayerData.stats.experience = stats["experience"]
	if save_data.has("coins"):
		PlayerData.coins = int(save_data["coins"])
		PlayerData.coins_changed.emit()	
	InventoryManager.clear_inventory()
	
	for slot_data in save_data["inventory"]["slots"]:
		var item := load(slot_data["item_path"]) as ItemData
		if item:
			var index: int = int(slot_data["index"])
			InventoryManager.slots[index] = {
				"item": item,
				"quantity": int(slot_data["quantity"])
			}
	
	for slot_name in save_data["inventory"]["equipped"]:
		var item := load(save_data["inventory"]["equipped"][slot_name]) as ItemData
		if item:
			InventoryManager.equipped[slot_name] = item
	
	if save_data["inventory"].has("collected_pickups"):
		InventoryManager.collected_pickups = save_data["inventory"]["collected_pickups"]
	
	InventoryManager.inventory_changed.emit()
	HUD.update_hearts()
	print("game loaded")
	return true

func has_save() -> bool:
	return FileAccess.file_exists(SAVE_PATH)
