extends CanvasLayer

var panel: Panel
var retry_button: Button
var load_button: Button
var quit_button: Button

func _ready() -> void:
	var current_scene = get_tree().current_scene
	print("IN SCENE:")
	print(current_scene.name)
	process_mode = Node.PROCESS_MODE_ALWAYS
	layer = 20
	visible = false
	_build_ui()

func _build_ui() -> void:
	panel = Panel.new()
	panel.set_anchors_preset(Control.PRESET_FULL_RECT)
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.05, 0.0, 0.0, 0.9)
	panel.add_theme_stylebox_override("panel", style)
	add_child(panel)

	var vbox := VBoxContainer.new()
	vbox.set_anchors_preset(Control.PRESET_CENTER)
	vbox.grow_horizontal = Control.GROW_DIRECTION_BOTH
	vbox.grow_vertical = Control.GROW_DIRECTION_BOTH
	vbox.custom_minimum_size = Vector2(200, 200)
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_theme_constant_override("separation", 16)
	panel.add_child(vbox)

	var title := Label.new()
	title.text = "GAME OVER"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 32)
	title.add_theme_color_override("font_color", Color(0.8, 0.1, 0.1))
	vbox.add_child(title)

	var spacer := Control.new()
	spacer.custom_minimum_size = Vector2(0, 20)
	vbox.add_child(spacer)

	retry_button = Button.new()
	retry_button.text = "Retry"
	retry_button.add_theme_font_size_override("font_size", 16)
	retry_button.pressed.connect(_on_retry)
	vbox.add_child(retry_button)

	load_button = Button.new()
	load_button.text = "Load Save"
	load_button.add_theme_font_size_override("font_size", 16)
	load_button.pressed.connect(_on_load_save)
	vbox.add_child(load_button)

	quit_button = Button.new()
	quit_button.text = "Quit to Menu"
	quit_button.add_theme_font_size_override("font_size", 16)
	quit_button.pressed.connect(_on_quit)
	vbox.add_child(quit_button)

func show_screen() -> void:
	load_button.disabled = not SaveManager.has_save()
	visible = true
	get_tree().paused = true
	retry_button.grab_focus()

func hide_screen() -> void:
	visible = false

func _reset_player() -> void:
	Player.is_dead = false
	Player.death_id += 1
	Player.set_physics_process(true)
	Player.get_node("AnimatedSprite2D").modulate.a = 1.0
	Player.is_invincible = false
	Player.is_attacking = false
	Player.state = Player.State.IDLE

func _on_retry() -> void:
	visible = false
	get_tree().paused = false
	_reset_player()
	Player.stats.current_health = Player.stats.max_health
	HUD.update_hearts()
	
	var current_scene_path := get_tree().current_scene.scene_file_path
	await TransitionManager.transition_to(current_scene_path)

func _on_load_save() -> void:
	visible = false
	get_tree().paused = false
	_reset_player()
	SaveManager.load_game()
	
	var current_scene_path := get_tree().current_scene.scene_file_path
	await TransitionManager.transition_to(current_scene_path)

func _on_quit() -> void:
	visible = false
	get_tree().paused = false
	_reset_player()
	HUD.hide()
	Player.hide()
	Player.disable_camera()
	TransitionManager.transition_to("res://scenes/ui/main_menu.tscn")
