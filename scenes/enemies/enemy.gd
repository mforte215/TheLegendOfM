extends CharacterBody2D
@export var stats: CharacterStats
@export var detection_range: float = 150.0
@export var knockback_strength: float = 150.0

# --- State Machine ---
enum State { IDLE, CHASE, HURT, DEAD }
var state := State.IDLE

# --- References ---
@onready var anim := $AnimatedSprite2D

var player: Node2D

func _ready() -> void:
	stats.current_health = stats.max_health
	if not $HurtboxArea.hurt.is_connected(take_damage):
		$HurtboxArea.hurt.connect(take_damage)
	set_physics_process(false)
	await get_tree().process_frame
	player = get_tree().get_first_node_in_group("player")
	await get_tree().create_timer(0.5).timeout
	set_physics_process(true)
	
	
func _physics_process(_delta: float) -> void:
	match state:
		State.IDLE:
			handle_idle()
		State.CHASE:
			handle_chase()
		State.HURT:
			move_and_slide()
		State.DEAD:
			pass
	check_hitbox()
# --- States ---
func handle_idle() -> void:
	velocity = Vector2.ZERO
	update_animation(Vector2.DOWN)
	
	if player and global_position.distance_to(player.global_position) < detection_range:
		state = State.CHASE

func handle_chase() -> void:
	if not player:
		return
	
	var direction := global_position.direction_to(player.global_position)
	velocity = direction * stats.speed
	move_and_slide()
	update_animation(direction)
	
	if global_position.distance_to(player.global_position) > detection_range * 1.2:
		state = State.IDLE

# --- Animation ---
func update_animation(direction: Vector2) -> void:
	var dir := get_direction_name(direction)
	
	match state:
		State.IDLE:
			anim.play("idle_" + dir)
		State.CHASE:
			anim.play("walk_" + dir)

func get_direction_name(direction: Vector2) -> String:
	if abs(direction.x) > abs(direction.y):
		return "right" if direction.x > 0 else "left"
	else:
		return "down" if direction.y > 0 else "up"

# --- Health ---
func take_damage(amount: int) -> void:
	if state == State.DEAD:
		return
	
	var actual_damage: int = max(amount - stats.defense, 1)
	stats.current_health -= actual_damage
	print("enemy took damage: ", actual_damage, " health remaining: ", stats.current_health)
	
	if stats.current_health <= 0:
		state = State.DEAD
		await hit_flash()  # flash before dying
		die()
	else:
		state = State.HURT
		apply_knockback()
		hit_flash()
		await get_tree().create_timer(0.4).timeout
		state = State.CHASE

func die() -> void:
	state = State.DEAD
	# death animation will go here
	await get_tree().create_timer(0.5).timeout
	queue_free()

func apply_knockback() -> void:
	if not player:
		return
	var direction := player.global_position.direction_to(global_position)
	velocity = direction * knockback_strength

func hit_flash() -> void:
	var sprite := $AnimatedSprite2D
	sprite.modulate = Color.WHITE * 10
	await get_tree().create_timer(0.1).timeout
	sprite.modulate = Color.WHITE

func check_hitbox() -> void:
	for area in $HitboxArea.get_overlapping_areas():
		if area.is_in_group("hurtbox") and area.owner != self:
			area.hurt.emit(stats.attack)
			

	
