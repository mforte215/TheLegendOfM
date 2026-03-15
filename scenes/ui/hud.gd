extends CanvasLayer

@onready var hearts_container := $MarginContainer/VBoxContainer/HeartsContainer
@onready var item_bar := $MarginContainer/VBoxContainer/ItemBar

var heart_textures: Array = []
const HEARTS: int = 3
const HP_PER_HEART: int = 4

var weapon_icon: TextureRect
var ranged_icon: TextureRect
var weapon_slot_bg: PanelContainer
var ranged_slot_bg: PanelContainer
var coin_label: Label

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
	
	_build_dual_weapon_slots()
	_build_coin_display()
	PlayerData.coins_changed.connect(update_coin_display)
	update_hearts()
	update_item_slots()
	InventoryManager.inventory_changed.connect(update_item_slots)
	InventoryManager.item_equipped.connect(_on_item_equipped)

func _build_dual_weapon_slots() -> void:
	for child in item_bar.get_children():
		child.queue_free()
	
	weapon_slot_bg = _create_slot_box("X")
	item_bar.add_child(weapon_slot_bg)
	weapon_icon = weapon_slot_bg.get_node("VBox/Icon")
	
	var spacer := Control.new()
	spacer.custom_minimum_size = Vector2(4, 0)
	item_bar.add_child(spacer)
	
	ranged_slot_bg = _create_slot_box("RT")
	item_bar.add_child(ranged_slot_bg)
	ranged_icon = ranged_slot_bg.get_node("VBox/Icon")

func _create_slot_box(button_label: String) -> PanelContainer:
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(32, 32)
	
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.1, 0.1, 0.15, 0.85)
	style.border_color = Color(0.4, 0.4, 0.5)
	style.set_border_width_all(1)
	style.set_corner_radius_all(2)
	panel.add_theme_stylebox_override("panel", style)
	
	var vbox := VBoxContainer.new()
	vbox.name = "VBox"
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	panel.add_child(vbox)
	
	var icon := TextureRect.new()
	icon.name = "Icon"
	icon.custom_minimum_size = Vector2(24, 24)
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	icon.visible = false
	vbox.add_child(icon)
	
	var label := Label.new()
	label.text = button_label
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 8)
	label.add_theme_color_override("font_color", Color(0.6, 0.6, 0.7))
	vbox.add_child(label)
	
	return panel

func update_hearts() -> void:
	var current_hp: int = PlayerData.stats.current_health
	
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

func update_item_slots() -> void:
	if InventoryManager.equipped.has("weapon"):
		var item: ItemData = InventoryManager.equipped["weapon"]
		weapon_icon.texture = item.icon
		weapon_icon.visible = true
	else:
		weapon_icon.visible = false
	
	if InventoryManager.equipped.has("ranged"):
		var item: ItemData = InventoryManager.equipped["ranged"]
		ranged_icon.texture = item.icon
		ranged_icon.visible = true
	else:
		ranged_icon.visible = false

func _on_item_equipped(_item: ItemData, _slot: String) -> void:
	update_item_slots()

func _build_coin_display() -> void:
	var coin_hbox := HBoxContainer.new()
	coin_hbox.add_theme_constant_override("separation", 4)
	$MarginContainer/VBoxContainer.add_child(coin_hbox)
	
	var coin_icon := TextureRect.new()
	coin_icon.custom_minimum_size = Vector2(16, 16)
	coin_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	coin_icon.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	# If you have a coin sprite, preload it here:
	coin_icon.texture = preload("res://assets/sprites/coin.png")
	coin_hbox.add_child(coin_icon)
	
	coin_label = Label.new()
	coin_label.add_theme_font_size_override("font_size", 12)
	coin_label.text = "0"
	coin_hbox.add_child(coin_label)

func update_coin_display() -> void:
	coin_label.text = str(PlayerData.coins)
