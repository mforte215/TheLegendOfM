extends CanvasLayer

signal dialogue_finished

@onready var name_label := $PanelContainer/MarginContainer/VBoxContainer/NameLabel
@onready var dialogue_label := $PanelContainer/MarginContainer/VBoxContainer/DialogueLabel
var typing_tween: Tween = null
var lines: Array = []
var current_line: int = 0
var is_open: bool = false
var is_typing: bool = false
var can_advance: bool = false
var type_id: int = 0
func _ready() -> void:
	hide()

func start(dialogue_lines: Array, speaker_name: String = "") -> void:
	lines = dialogue_lines
	current_line = 0
	is_open = true
	can_advance = false
	
	if speaker_name != "":
		name_label.text = speaker_name
		name_label.visible = true
	else:
		name_label.visible = false
	
	show()
	await get_tree().process_frame  # Wait one frame before typing
	display_line()
	await get_tree().create_timer(0.2).timeout
	can_advance = true
	
func display_line() -> void:
	dialogue_label.text = ""
	type_id += 1
	type_line(lines[current_line], type_id)

func type_line(line: String, id: int) -> void:
	is_typing = true
	dialogue_label.text = ""
	
	for character in line:
		if type_id != id:
			return  # A newer type_line has started, stop this one
		dialogue_label.text += character
		await get_tree().create_timer(0.03).timeout
	
	is_typing = false
func next_line() -> void:
	if is_typing:
		is_typing = false
		type_id += 1  # Cancel the running coroutine
		dialogue_label.text = lines[current_line]
		return
	
	current_line += 1
	
	if current_line >= lines.size():
		close()
	else:
		display_line()

func close() -> void:
	is_open = false
	lines = []
	current_line = 0
	hide()
	
func _input(event: InputEvent) -> void:
	if not is_open or not can_advance:
		return
	if Input.is_action_just_pressed("interact"):
		can_advance = false
		next_line()
		await get_tree().create_timer(0.1).timeout
		can_advance = true
