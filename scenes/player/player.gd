extends CharacterBody2D

@export var speed: float = 150.0
@export var sprint_speed: float = 250.0  # Add this

var facing := Vector2.DOWN

enum State { IDLE, MOVE, SPRINT }  # Add SPRINT
var state := State.IDLE

func _physics_process(_delta: float) -> void:
	var input := Vector2(
		Input.get_axis("ui_left", "ui_right"),
		Input.get_axis("ui_up", "ui_down")
	).normalized()

	var is_sprinting := Input.is_action_pressed("sprint")  # Add this

	if input != Vector2.ZERO:
		facing = input
		# Use sprint speed if sprinting
		velocity = input * (sprint_speed if is_sprinting else speed)
		state = State.SPRINT if is_sprinting else State.MOVE
	else:
		velocity = Vector2.ZERO
		state = State.IDLE

	move_and_slide()
	update_animation()

func update_animation() -> void:
	var anim := $AnimatedSprite2D
	var dir := get_direction_name()

	match state:
		State.IDLE:
			anim.play("idle_" + dir)
		State.MOVE:
			anim.play("walk_" + dir)
		State.SPRINT:
			anim.play("walk_" + dir)  # Reuses walk animation for now

func get_direction_name() -> String:
	if abs(facing.x) > abs(facing.y):
		return "right" if facing.x > 0 else "left"
	else:
		return "down" if facing.y > 0 else "up"
