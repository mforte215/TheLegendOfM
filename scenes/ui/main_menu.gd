extends Node2D

@onready var music := $Music
@onready var continue_button := $UILayer/VBoxContainer/ButtonContainer/Continue

func _ready() -> void:
	HUD.hide()
	Player.hide()
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
	Player.is_dead = false
	Player.set_physics_process(true)
	Player.get_node("AnimatedSprite2D").modulate.a = 1.0
	Player.is_invincible = false
	Player.is_attacking = false
	Player.state = Player.State.IDLE
	InventoryManager.clear_inventory()
	Player.stats.current_health = Player.stats.max_health
	HUD.update_hearts()
	await TransitionManager.transition_to("res://scenes/world/test_room.tscn")
	Player.show()
	Player.enable_camera()
	HUD.show()
	HUD.update_hearts()

func _on_continue() -> void:
	Player.is_dead = false
	Player.set_physics_process(true)
	Player.get_node("AnimatedSprite2D").modulate.a = 1.0
	Player.is_invincible = false
	Player.is_attacking = false
	Player.state = Player.State.IDLE
	SaveManager.load_game()
	await TransitionManager.transition_to("res://scenes/world/test_room.tscn")
	Player.enable_camera()
	Player.show()
	HUD.show()

func _on_options() -> void:
	pass

func _on_quit() -> void:
	get_tree().quit()
