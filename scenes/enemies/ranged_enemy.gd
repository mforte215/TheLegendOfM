extends CharacterBody2D

@export var stats: CharacterStats
@export var detection_range: float = 200.0
@export var attack_range: float = 150.0
@export var retreat_range: float = 80.0
@export var knockback_strength: float = 150.0
@export var fire_cooldown: float = 2.0

enum State { IDLE, APPROACH, ATTACK, RETREAT, HURT, DEAD }
var state := State.IDLE

@onready var anim := $AnimatedSprite2D
var player: Node2D
var can_fire := true
var projectile_scene: PackedScene = preload("res://scenes/projectiles/enemy_projectile.tscn")

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
		State.APPROACH:
			handle_approach()
		State.ATTACK:
			handle_attack()
		State.RETREAT:
			handle_retreat()
		State.HURT:
			move_and_slide()
		State.DEAD:
			pass

func handle_idle() -> void:
	velocity = Vector2.ZERO
	update_animation(Vector2.DOWN)
	
	if player and global_position.distance_to(player.global_position) < detection_range:
		state = State.APPROACH

func handle_approach() -> void:
	if not player:
		return
	
	var dist := global_position.distance_to(player.global_position)
	var direction := global_position.direction_to(player.global_position)
	
	# Close enough to attack
	if dist <= attack_range:
		velocity = Vector2.ZERO
		state = State.ATTACK
		update_animation(direction)
		return
	
	# Too far, lost interest
	if dist > detection_range * 1.2:
		state = State.IDLE
		return
	
	# Move toward player
	velocity = direction * stats.speed
	move_and_slide()
	update_animation(direction)

func handle_attack() -> void:
	if not player:
		return
	
	var dist := global_position.distance_to(player.global_position)
	var direction := global_position.direction_to(player.global_position)
	
	velocity = Vector2.ZERO
	update_animation(direction)
	
	# Too close, back up
	if dist < retreat_range:
		state = State.RETREAT
		return
	
	# Too far, chase again
	if dist > attack_range * 1.2:
		state = State.APPROACH
		return
	
	# Fire if ready
	if can_fire:
		fire_projectile(direction)

func handle_retreat() -> void:
	if not player:
		return
	
	var dist := global_position.distance_to(player.global_position)
	var direction := global_position.direction_to(player.global_position)
	
	# Move away from player
	velocity = -direction * stats.speed
	move_and_slide()
	update_animation(-direction)
	
	# Far enough, stop retreating
	if dist >= attack_range * 0.8:
		state = State.ATTACK

func fire_projectile(direction: Vector2) -> void:
	can_fire = false
	
	var projectile = projectile_scene.instantiate()
	
	# Snap to 4 directions
	var fire_dir: Vector2
	if abs(direction.x) > abs(direction.y):
		fire_dir = Vector2(sign(direction.x), 0)
	else:
		fire_dir = Vector2(0, sign(direction.y))
	
	projectile.direction = fire_dir
	projectile.damage = stats.attack
	get_tree().current_scene.add_child(projectile)
	projectile.global_position = global_position + (fire_dir * 20.0)
	
	# Cooldown
	await get_tree().create_timer(fire_cooldown).timeout
	if state != State.DEAD:
		can_fire = true

# --- Animation ---
func update_animation(direction: Vector2) -> void:
	var dir := get_direction_name(direction)
	
	match state:
		State.IDLE:
			anim.play("idle_" + dir)
		State.APPROACH, State.RETREAT:
			anim.play("walk_" + dir)
		State.ATTACK:
			anim.play("idle_" + dir)

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
	print("ranged enemy took damage: ", actual_damage, " health remaining: ", stats.current_health)
	
	if stats.current_health <= 0:
		state = State.DEAD
		await hit_flash()
		die()
	else:
		state = State.HURT
		apply_knockback()
		hit_flash()
		await get_tree().create_timer(0.4).timeout
		state = State.APPROACH

func die() -> void:
	state = State.DEAD
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
