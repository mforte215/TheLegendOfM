extends CanvasLayer

@onready var resume_button := $ColorRect/VBoxContainer/Resume
@onready var save_button := $ColorRect/VBoxContainer/SaveGame
@onready var options_button := $ColorRect/VBoxContainer/Options
@onready var quit_button := $ColorRect/VBoxContainer/Quit
var can_toggle: bool = true
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hide()
	process_mode = Node.PROCESS_MODE_ALWAYS
	resume_button.pressed.connect(_on_resume)
	save_button.pressed.connect(_on_save)
	options_button.pressed.connect(_on_options)
	quit_button.pressed.connect(_on_quit)

func _input(event: InputEvent) -> void:
	if not can_toggle:
		return
	if Input.is_action_just_pressed("pause_toggle"):
		can_toggle = false
		if visible:
			print("CLOSING")
			close()
		else:
			open()
		await get_tree().create_timer(0.1).timeout
		can_toggle = true

func open() -> void:
	show()
	get_tree().paused = true
	resume_button.grab_focus()

func close() -> void:
	print("closing pause menu")
	get_tree().paused = false
	hide()
	print("paused: ", get_tree().paused)

func _on_resume() -> void:
	close()

func _on_save() -> void:
	SaveManager.save_game()

func _on_options() -> void:
	pass  # build later

func _on_quit() -> void:
	close()
	HUD.hide()
	Player.hide()
	Player.disable_camera()
	TransitionManager.transition_to("res://scenes/ui/main_menu.tscn")
