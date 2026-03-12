extends CanvasLayer

signal closed

var grid_container: GridContainer
var description_label: Label
var item_name_label: Label
var weapon_equip_icon: TextureRect
var ranged_equip_icon: TextureRect

var cursor_index: int = 0
var is_open: bool = false
var slot_nodes: Array = []

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	layer = 10
	visible = false
	_build_ui()
	_build_grid()
	InventoryManager.inventory_changed.connect(_refresh_grid)

func _build_ui() -> void:
	# Panel - dark background, full screen
	var panel := Panel.new()
	panel.set_anchors_preset(Control.PRESET_FULL_RECT)
	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = Color(0.05, 0.05, 0.1, 0.95)
	panel.add_theme_stylebox_override("panel", panel_style)
	add_child(panel)

	# MarginContainer - generous margins for fullscreen
	var margin := MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 40)
	margin.add_theme_constant_override("margin_right", 40)
	margin.add_theme_constant_override("margin_top", 30)
	margin.add_theme_constant_override("margin_bottom", 30)
	panel.add_child(margin)

	# Main horizontal split: left side (grid + description) | right side (equipped)
	var hbox := HBoxContainer.new()
	hbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
	hbox.add_theme_constant_override("separation", 30)
	margin.add_child(hbox)

	# === LEFT SIDE: inventory grid + description ===
	var left_vbox := VBoxContainer.new()
	left_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	left_vbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
	left_vbox.size_flags_stretch_ratio = 3.0
	left_vbox.add_theme_constant_override("separation", 10)
	hbox.add_child(left_vbox)

	# Title
	var title := Label.new()
	title.text = "INVENTORY"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 20)
	title.add_theme_color_override("font_color", Color(1.0, 0.85, 0.0))
	left_vbox.add_child(title)

	# Item name
	item_name_label = Label.new()
	item_name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	item_name_label.add_theme_font_size_override("font_size", 14)
	left_vbox.add_child(item_name_label)

	# Grid - centered
	var grid_center := CenterContainer.new()
	grid_center.size_flags_vertical = Control.SIZE_EXPAND_FILL
	left_vbox.add_child(grid_center)

	grid_container = GridContainer.new()
	grid_container.add_theme_constant_override("h_separation", 4)
	grid_container.add_theme_constant_override("v_separation", 4)
	grid_center.add_child(grid_container)

	# Description panel
	var desc_panel := PanelContainer.new()
	var desc_style := StyleBoxFlat.new()
	desc_style.bg_color = Color(0.1, 0.1, 0.15, 0.9)
	desc_style.set_corner_radius_all(4)
	desc_style.set_content_margin_all(8)
	desc_panel.add_theme_stylebox_override("panel", desc_style)
	desc_panel.custom_minimum_size.y = 60
	left_vbox.add_child(desc_panel)

	description_label = Label.new()
	description_label.add_theme_font_size_override("font_size", 12)
	description_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	desc_panel.add_child(description_label)

	# === RIGHT SIDE: equipped panel ===
	var right_vbox := VBoxContainer.new()
	right_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	right_vbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
	right_vbox.size_flags_stretch_ratio = 1.0
	right_vbox.add_theme_constant_override("separation", 10)
	hbox.add_child(right_vbox)

	# Equipped title
	var equip_title := Label.new()
	equip_title.text = "EQUIPPED"
	equip_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	equip_title.add_theme_font_size_override("font_size", 20)
	equip_title.add_theme_color_override("font_color", Color(1.0, 0.85, 0.0))
	right_vbox.add_child(equip_title)

	# Weapon slot
	weapon_equip_icon = _create_equip_slot("Weapon [X]", right_vbox)

	# Ranged slot
	ranged_equip_icon = _create_equip_slot("Ranged [RT]", right_vbox)

	# Spacer to push everything up
	var spacer := Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	right_vbox.add_child(spacer)

func _create_equip_slot(label_text: String, parent: VBoxContainer) -> TextureRect:
	# Label
	var label := Label.new()
	label.text = label_text
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 12)
	label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.8))
	parent.add_child(label)

	# Slot box
	var slot_panel := PanelContainer.new()
	slot_panel.custom_minimum_size = Vector2(64, 64)
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.12, 0.12, 0.18, 0.9)
	style.border_color = Color(0.5, 0.5, 0.6)
	style.set_border_width_all(2)
	style.set_corner_radius_all(4)
	slot_panel.add_theme_stylebox_override("panel", style)
	parent.add_child(slot_panel)

	var center := CenterContainer.new()
	slot_panel.add_child(center)

	var icon := TextureRect.new()
	icon.custom_minimum_size = Vector2(48, 48)
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	icon.visible = false
	center.add_child(icon)

	return icon

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("inventory"):
		if is_open:
			close()
		else:
			open()
		get_viewport().set_input_as_handled()
		return

	if not is_open:
		return

	if event.is_action_pressed("ui_right"):
		move_cursor(1, 0)
	elif event.is_action_pressed("ui_left"):
		move_cursor(-1, 0)
	elif event.is_action_pressed("ui_down"):
		move_cursor(0, 1)
	elif event.is_action_pressed("ui_up"):
		move_cursor(0, -1)
	elif event.is_action_pressed("ui_accept"):
		_select_current()

	get_viewport().set_input_as_handled()

func open() -> void:
	is_open = true
	visible = true
	get_tree().paused = true
	cursor_index = 0
	_refresh_grid()
	_update_cursor()

func close() -> void:
	is_open = false
	visible = false
	get_tree().paused = false
	closed.emit()

func move_cursor(dx: int, dy: int) -> void:
	var col: int = cursor_index % InventoryManager.GRID_COLUMNS
	var row: int = cursor_index / InventoryManager.GRID_COLUMNS
	col = clampi(col + dx, 0, InventoryManager.GRID_COLUMNS - 1)
	row = clampi(row + dy, 0, InventoryManager.GRID_ROWS - 1)
	cursor_index = row * InventoryManager.GRID_COLUMNS + col
	_update_cursor()

func _select_current() -> void:
	InventoryManager.use_item(cursor_index)
	_refresh_grid()

func _build_grid() -> void:
	grid_container.columns = InventoryManager.GRID_COLUMNS
	for i in InventoryManager.MAX_SLOTS:
		var slot := _create_slot_node()
		grid_container.add_child(slot)
		slot_nodes.append(slot)

func _create_slot_node() -> PanelContainer:
	var slot := PanelContainer.new()
	slot.custom_minimum_size = Vector2(56, 56)

	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.15, 0.15, 0.2, 0.9)
	style.border_color = Color(0.4, 0.4, 0.5)
	style.set_border_width_all(2)
	style.set_corner_radius_all(2)
	slot.add_theme_stylebox_override("panel", style)

	var center := CenterContainer.new()
	center.name = "CenterContainer"
	slot.add_child(center)

	var icon := TextureRect.new()
	icon.name = "Icon"
	icon.custom_minimum_size = Vector2(40, 40)
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	center.add_child(icon)

	var qty_label := Label.new()
	qty_label.name = "QuantityLabel"
	qty_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	qty_label.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM
	qty_label.add_theme_font_size_override("font_size", 10)
	qty_label.text = ""
	slot.add_child(qty_label)

	return slot

func _refresh_grid() -> void:
	var equipped_items: Array = InventoryManager.equipped.values()

	for i in InventoryManager.MAX_SLOTS:
		var slot_data = InventoryManager.get_slot(i)
		var slot_node: PanelContainer = slot_nodes[i]
		var icon: TextureRect = slot_node.get_node("CenterContainer/Icon")
		var qty_label: Label = slot_node.get_node("QuantityLabel")

		if slot_data != null:
			icon.texture = slot_data["item"].icon
			if slot_data["item"] in equipped_items:
				qty_label.text = "E"
			elif slot_data["item"].stackable and slot_data["quantity"] > 1:
				qty_label.text = str(slot_data["quantity"])
			else:
				qty_label.text = ""
		else:
			icon.texture = null
			qty_label.text = ""

	_update_description()
	_update_equipped_display()

func _update_cursor() -> void:
	for i in InventoryManager.MAX_SLOTS:
		var slot_node: PanelContainer = slot_nodes[i]
		var style: StyleBoxFlat = slot_node.get_theme_stylebox("panel") as StyleBoxFlat
		if i == cursor_index:
			style.border_color = Color(1.0, 0.85, 0.0)
			style.set_border_width_all(3)
		else:
			style.border_color = Color(0.4, 0.4, 0.5)
			style.set_border_width_all(2)
	_update_description()

func _update_description() -> void:
	var slot_data = InventoryManager.get_slot(cursor_index)
	if slot_data != null:
		item_name_label.text = slot_data["item"].item_name
		description_label.text = slot_data["item"].description
		match slot_data["item"].item_type:
			ItemData.ItemType.EQUIPMENT:
				description_label.text += "\n[Press Enter to equip]"
			ItemData.ItemType.USABLE, ItemData.ItemType.CONSUMABLE:
				description_label.text += "\n[Press Enter to use]"
	else:
		item_name_label.text = ""
		description_label.text = "Empty slot"

func _update_equipped_display() -> void:
	# Weapon slot
	if InventoryManager.equipped.has("weapon"):
		weapon_equip_icon.texture = InventoryManager.equipped["weapon"].icon
		weapon_equip_icon.visible = true
	else:
		weapon_equip_icon.visible = false

	# Ranged slot
	if InventoryManager.equipped.has("ranged"):
		ranged_equip_icon.texture = InventoryManager.equipped["ranged"].icon
		ranged_equip_icon.visible = true
	else:
		ranged_equip_icon.visible = false
