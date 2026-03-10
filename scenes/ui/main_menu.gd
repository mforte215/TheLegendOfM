extends Node2D

@onready var music := $Music
@onready var continue_button := $UILayer/VBoxContainer/ButtonContainer/Continue

func _ready() -> void:
	HUD.hide()
	Player.hide()
	music.finished.connect(_on_music_finished)
	
	# Disable continue if no save exists
	continue_button.disabled = not SaveManager.has_save()
	
	# Connect buttons
	$UILayer/VBoxContainer/ButtonContainer/NewGame.pressed.connect(_on_new_game)
	$UILayer/VBoxContainer/ButtonContainer/Continue.pressed.connect(_on_continue)
	$UILayer/VBoxContainer/ButtonContainer/Options.pressed.connect(_on_options)
	$UILayer/VBoxContainer/ButtonContainer/Quit.pressed.connect(_on_quit)
	$UILayer/VBoxContainer/ButtonContainer/NewGame.grab_focus()
	
func _on_music_finished() -> void:
	music.play()

func _on_new_game() -> void:
	InventoryManager.clear_inventory()
	Player.stats.current_health = Player.stats.max_health
	await TransitionManager.transition_to("res://scenes/world/test_room.tscn")
	Player.show()
	Player.enable_camera()
	HUD.show()
	HUD.update_hearts()

func _on_continue() -> void:
	SaveManager.load_game()
	await TransitionManager.transition_to("res://scenes/world/test_room.tscn")
	Player.enable_camera()
	Player.show()
	HUD.show()

func _on_options() -> void:
	pass  # build later

func _on_quit() -> void:
	get_tree().quit()
