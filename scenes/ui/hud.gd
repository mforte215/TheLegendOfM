extends CanvasLayer

@onready var hearts_container := $MarginContainer/VBoxContainer/HeartsContainer
@onready var item_icon := $MarginContainer/VBoxContainer/ItemBar/ItemSlotBG/ItemIcon

var heart_textures: Array = []
const HEARTS: int = 3
const HP_PER_HEART: int = 4

func _ready() -> void:
	heart_textures = [
		preload("res://assets/sprites/heart_0.png"),
		preload("res://assets/sprites/heart_1.png"),
		preload("res://assets/sprites/heart_2.png"),
		preload("res://assets/sprites/heart_3.png"),
		preload("res://assets/sprites/heart_4.png")
	]
	
	for i in HEARTS:
		var heart := TextureRect.new()
		heart.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		heart.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
		heart.custom_minimum_size = Vector2(24, 24)
		hearts_container.add_child(heart)
	
	update_hearts()
	update_item_slot()
	InventoryManager.inventory_changed.connect(update_item_slot)
	InventoryManager.item_equipped.connect(_on_item_equipped)

func update_hearts() -> void:
	var current_hp: int = Player.stats.current_health
	
	for i in HEARTS:
		var heart := hearts_container.get_child(i)
		var heart_hp: int = current_hp - (i * HP_PER_HEART)
		
		if heart_hp <= 0:
			heart.texture = heart_textures[0]
		elif heart_hp == 1:
			heart.texture = heart_textures[1]
		elif heart_hp == 2:
			heart.texture = heart_textures[2]
		elif heart_hp == 3:
			heart.texture = heart_textures[3]
		else:
			heart.texture = heart_textures[4]

func update_item_slot() -> void:
	if InventoryManager.equipped.is_empty():
		item_icon.visible = false
	else:
		var item: ItemData = null
		if InventoryManager.equipped.has("weapon"):
			item = InventoryManager.equipped["weapon"]
		else:
			item = InventoryManager.equipped.values()[0]
		
		if item != null:
			item_icon.texture = item.icon
			item_icon.visible = true
		else:
			item_icon.visible = false

func _on_item_equipped(_item: ItemData, _slot: String) -> void:
	update_item_slot()
