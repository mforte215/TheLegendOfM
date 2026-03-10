extends CanvasLayer

signal closed

var grid_container: GridContainer
var description_label: Label
var item_name_label: Label
var equipped_label: Label

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
	# Panel - dark background
	var panel := Panel.new()
	panel.anchor_right = 1.0
	panel.anchor_bottom = 1.0
	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = Color(0.05, 0.05, 0.1, 0.92)
	panel.add_theme_stylebox_override("panel", panel_style)
	add_child(panel)

	# MarginContainer
	var margin := MarginContainer.new()
	margin.anchor_right = 1.0
	margin.anchor_bottom = 1.0
	margin.add_theme_constant_override("margin_left", 20)
	margin.add_theme_constant_override("margin_right", 20)
	margin.add_theme_constant_override("margin_top", 20)
	margin.add_theme_constant_override("margin_bottom", 20)
	panel.add_child(margin)

	# VBoxContainer
	var vbox := VBoxContainer.new()
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
	margin.add_child(vbox)

	# Item name
	item_name_label = Label.new()
	item_name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	item_name_label.add_theme_font_size_override("font_size", 16)
	vbox.add_child(item_name_label)

	# Grid
	grid_container = GridContainer.new()
	grid_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_child(grid_container)

	# Description panel
	var desc_panel := PanelContainer.new()
	var desc_style := StyleBoxFlat.new()
	desc_style.bg_color = Color(0.1, 0.1, 0.15, 0.9)
	desc_style.set_corner_radius_all(4)
	desc_panel.add_theme_stylebox_override("panel", desc_style)
	vbox.add_child(desc_panel)

	description_label = Label.new()
	description_label.add_theme_font_size_override("font_size", 12)
	description_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	description_label.custom_minimum_size.y = 50
	desc_panel.add_child(description_label)

	# Equipped label
	equipped_label = Label.new()
	equipped_label.add_theme_font_size_override("font_size", 12)
	vbox.add_child(equipped_label)

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
	slot.custom_minimum_size = Vector2(40, 40)

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
	icon.custom_minimum_size = Vector2(32, 32)
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
	for i in InventoryManager.MAX_SLOTS:
		var slot_data = InventoryManager.get_slot(i)
		var slot_node: PanelContainer = slot_nodes[i]
		var icon: TextureRect = slot_node.get_node("CenterContainer/Icon")
		var qty_label: Label = slot_node.get_node("QuantityLabel")

		if slot_data != null:
			icon.texture = slot_data["item"].icon
			if slot_data["item"].stackable and slot_data["quantity"] > 1:
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
	var text := "Equipped: "
	var parts: Array = []
	for slot_name in InventoryManager.equipped:
		var item: ItemData = InventoryManager.equipped[slot_name]
		parts.append(slot_name.capitalize() + ": " + item.item_name)
	if parts.is_empty():
		text += "Nothing"
	else:
		text += ", ".join(parts)
	equipped_label.text = text
