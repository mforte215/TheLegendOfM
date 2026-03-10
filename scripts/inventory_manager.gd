extends Node

signal inventory_changed
signal item_used(item: ItemData)
signal item_equipped(item: ItemData, slot: String)

const GRID_COLUMNS: int = 6
const GRID_ROWS: int = 4
const MAX_SLOTS: int = GRID_COLUMNS * GRID_ROWS  # 24

# Each slot is { "item": ItemData, "quantity": int } or null
var slots: Array = []

# Currently equipped items by slot name
var equipped: Dictionary = {}

func _ready() -> void:
	slots.resize(MAX_SLOTS)
	for i in MAX_SLOTS:
		slots[i] = null

# --- Adding Items ---

func add_item(item: ItemData, quantity: int = 1) -> bool:
	# If stackable, try existing stacks first
	print("ADDING ITEM")
	print("Is item stackable:")
	print(item.stackable)
	if item.stackable:
		for i in MAX_SLOTS:
			if slots[i] != null and slots[i]["item"].id == item.id:
				var space: int = item.max_stack - slots[i]["quantity"]
				if space > 0:
					var to_add: int = min(quantity, space)
					slots[i]["quantity"] += to_add
					quantity -= to_add
					if quantity <= 0:
						inventory_changed.emit()
						return true

	# Place remaining in empty slots
	while quantity > 0:
		var empty_idx: int = _find_empty_slot()
		if empty_idx == -1:
			inventory_changed.emit()
			return false  # Full

		var stack_amount: int = min(quantity, item.max_stack) if item.stackable else 1
		slots[empty_idx] = { "item": item, "quantity": stack_amount }
		quantity -= stack_amount

	inventory_changed.emit()
	return true

func remove_item(item_id: String, quantity: int = 1) -> bool:
	for i in MAX_SLOTS:
		if slots[i] != null and slots[i]["item"].id == item_id:
			if slots[i]["quantity"] >= quantity:
				slots[i]["quantity"] -= quantity
				if slots[i]["quantity"] <= 0:
					slots[i] = null
				inventory_changed.emit()
				return true
			else:
				quantity -= slots[i]["quantity"]
				slots[i] = null
	inventory_changed.emit()
	return quantity <= 0

func use_item(slot_index: int) -> void:
	if slot_index < 0 or slot_index >= MAX_SLOTS:
		return
	if slots[slot_index] == null:
		return

	var item: ItemData = slots[slot_index]["item"]

	match item.item_type:
		ItemData.ItemType.USABLE, ItemData.ItemType.CONSUMABLE:
			item_used.emit(item)
			remove_item(item.id, 1)
		ItemData.ItemType.EQUIPMENT:
			equip_item(slot_index)
		ItemData.ItemType.KEY_ITEM:
			pass  # Used by world objects, not from inventory

func equip_item(slot_index: int) -> void:
	if slots[slot_index] == null:
		return
	var item: ItemData = slots[slot_index]["item"]
	if item.item_type != ItemData.ItemType.EQUIPMENT or item.equip_slot == "":
		return

	# Swap with currently equipped
	var old_equipped: ItemData = equipped.get(item.equip_slot, null)
	equipped[item.equip_slot] = item
	slots[slot_index] = null

	if old_equipped:
		add_item(old_equipped, 1)

	item_equipped.emit(item, item.equip_slot)
	inventory_changed.emit()

func has_item(item_id: String) -> bool:
	for i in MAX_SLOTS:
		if slots[i] != null and slots[i]["item"].id == item_id:
			return true
	return false

func get_item_count(item_id: String) -> int:
	var total: int = 0
	for i in MAX_SLOTS:
		if slots[i] != null and slots[i]["item"].id == item_id:
			total += slots[i]["quantity"]
	return total

func get_slot(index: int):
	if index < 0 or index >= MAX_SLOTS:
		return null
	return slots[index]

func _find_empty_slot() -> int:
	for i in MAX_SLOTS:
		if slots[i] == null:
			return i
	return -1
