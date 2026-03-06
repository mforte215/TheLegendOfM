extends CharacterBody2D

# --- Stats ---
@export var max_health: int = 3
@export var move_speed: float = 40.0
@export var detection_range: float = 150.0
@export var attack_damage: int = 1
@export var knockback_strength: float = 150.0
var health: int

# --- State Machine ---
enum State { IDLE, CHASE, HURT, DEAD }
var state := State.IDLE

# --- References ---
@onready var anim := $AnimatedSprite2D

var player: Node2D

func _ready() -> void:
	health = max_health
	player = get_tree().get_first_node_in_group("player")
	if not $HurtboxArea.hurt.is_connected(take_damage):
		$HurtboxArea.hurt.connect(take_damage)
	$HurtboxArea.area_entered.connect(_on_hitbox_area_entered)
	
	
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
	velocity = direction * move_speed
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
	
	health -= amount
	
	if health <= 0:
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
	sprite.modulate = Color.WHITE * 10  # bright white flash
	await get_tree().create_timer(0.1).timeout
	sprite.modulate = Color.WHITE  # back to normal
	
func _on_hitbox_area_entered(area: Node) -> void:
	print("enemy hitbox detected: ", area.name, " groups: ", area.get_groups())
	if area.is_in_group("hurtbox"):
		area.hurt.emit(attack_damage)


func _on_hurtbox_area_hurt(amount: int) -> void:
	print("Hello")

func check_hitbox() -> void:
	for area in $HitboxArea.get_overlapping_areas():
		if area.is_in_group("hurtbox") and area.owner != self:
			area.hurt.emit(attack_damage)
			

	
