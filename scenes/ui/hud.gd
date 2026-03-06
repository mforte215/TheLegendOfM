extends CanvasLayer

@onready var hearts_container := $MarginContainer/VBoxContainer/HeartsContainer
@onready var item_icon := $MarginContainer/VBoxContainer/ItemBar/ItemSlotBG/ItemIcon

var heart_textures: Array = []
const HEARTS: int = 3
const HP_PER_HEART: int = 4
var equipped_item: ItemData = null

func _ready() -> void:
	# Load heart textures
	heart_textures = [
		preload("res://assets/sprites/heart_0.png"),
		preload("res://assets/sprites/heart_1.png"),
		preload("res://assets/sprites/heart_2.png"),
		preload("res://assets/sprites/heart_3.png"),
		preload("res://assets/sprites/heart_4.png")
	]
	
	# Create heart TextureRects
	for i in HEARTS:
		var heart := TextureRect.new()
		heart.stretch_mode = TextureRect.STRETCH_KEEP
		hearts_container.add_child(heart)
	
	update_hearts()
	update_item_slot()
func update_hearts() -> void:
	var current_hp: int = Player.stats.current_health
	
	for i in HEARTS:
		var heart := hearts_container.get_child(i)
		var heart_hp: int = current_hp - (i * HP_PER_HEART)
		
		if heart_hp <= 0:
			heart.texture = heart_textures[0]  # empty
		elif heart_hp == 1:
			heart.texture = heart_textures[1]  # 1/4
		elif heart_hp == 2:
			heart.texture = heart_textures[2]  # 1/2
		elif heart_hp == 3:
			heart.texture = heart_textures[3]  # 3/4
		else:
			heart.texture = heart_textures[4]  # full

func update_item_slot() -> void:
	var equipped := Player.stats.inventory.equipped_item
	
	if equipped == null:
		item_icon.visible = false
	else:
		item_icon.texture = equipped.icon
		item_icon.visible = true
