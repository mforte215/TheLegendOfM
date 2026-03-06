extends Resource
class_name Inventory

signal item_added
signal item_removed
signal inventory_changed

@export var items: Array = []
@export var max_size: int = 20

func add_item(item: ItemData) -> bool:
	if items.size() >= max_size:
		return false
	items.append(item)
	item_added.emit()
	inventory_changed.emit()
	return true

func remove_item(item: ItemData) -> bool:
	var index: int = items.find(item)
	if index == -1:
		return false
	items.remove_at(index)
	item_removed.emit()
	inventory_changed.emit()
	return true

func has_item(item: ItemData) -> bool:
	return items.has(item)
