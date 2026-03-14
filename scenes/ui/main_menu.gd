extends Node2D

@onready var music := $Music
@onready var continue_button := $UILayer/VBoxContainer/ButtonContainer/Continue

func _ready() -> void:
	HUD.hide()
	GameOver.hide_screen()
	music.finished.connect(_on_music_finished)
	
	continue_button.disabled = not SaveManager.has_save()
	
	$UILayer/VBoxContainer/ButtonContainer/NewGame.pressed.connect(_on_new_game)
	$UILayer/VBoxContainer/ButtonContainer/Continue.pressed.connect(_on_continue)
	$UILayer/VBoxContainer/ButtonContainer/Options.pressed.connect(_on_options)
	$UILayer/VBoxContainer/ButtonContainer/Quit.pressed.connect(_on_quit)
	$UILayer/VBoxContainer/ButtonContainer/NewGame.grab_focus()

func _on_music_finished() -> void:
	music.play()

func _on_new_game() -> void:
	GameOver.hide_screen()
	PlayerData.reset()
	InventoryManager.clear_inventory()
	HUD.update_hearts()
	await TransitionManager.transition_to("res://scenes/world/village.tscn")
	HUD.show()
	HUD.update_hearts()

func _on_continue() -> void:
	GameOver.hide_screen()
	PlayerData.reset()
	SaveManager.load_game()
	await TransitionManager.transition_to("res://scenes/world/village.tscn")
	HUD.show()
	HUD.update_hearts()

func _on_options() -> void:
	pass

func _on_quit() -> void:
	get_tree().quit()
