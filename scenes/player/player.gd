extends CharacterBody2D
@export var stats: CharacterStats
@export var speed: float = 150.0
@export var sprint_speed: float = 250.0  # Add this
@export var attack_damage: int = 1
var is_attacking := false
var facing := Vector2.DOWN
@export var invincibility_time: float = 1.0
var is_invincible: bool = false
enum State { IDLE, MOVE, SPRINT, ATTACK }
var state := State.IDLE
var projectile_scene: PackedScene = preload("res://scenes/projectiles/projectile.tscn")

func _ready() -> void:
	$Camera2D.enabled = false
	process_mode = Node.PROCESS_MODE_PAUSABLE
	stats.current_health = stats.max_health
	$HitboxArea/CollisionShape2D.disabled = true
	$HurtboxArea.hurt.connect(take_damage)
	
	print("HurtboxArea: ", $HurtboxArea)
	print("HurtboxArea owner: ", $HurtboxArea.owner)
	
func _physics_process(_delta: float) -> void:
	if Input.is_action_just_pressed("attack") and not is_attacking:
		attack()
		return
	
	if Input.is_action_just_pressed("ranged_attack") and not is_attacking:
		ranged_attack()
		return
	
	if is_attacking:
		return  # Don't let movement overwrite attack state

	var input := Vector2(
		Input.get_axis("ui_left", "ui_right"),
		Input.get_axis("ui_up", "ui_down")
	).normalized()
	var is_sprinting := Input.is_action_pressed("sprint")
	if input != Vector2.ZERO:
		facing = input
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
		State.ATTACK:
			print("Playing attack animation")
			anim.play("punch_" + dir)


func get_direction_name() -> String:
	if abs(facing.x) > abs(facing.y):
		return "right" if facing.x > 0 else "left"
	else:
		return "down" if facing.y > 0 else "up"
		
func place_at(pos: Vector2) -> void:
	global_position = pos
	
func attack() -> void:
	is_attacking = true
	state = State.ATTACK
	velocity = Vector2.ZERO  # Stop movement during attack
	position_hitbox()
	
	$HitboxArea/CollisionShape2D.disabled = false
	$HitboxArea.damage = stats.attack
	
	# Play the animation and wait for it to finish
	var dir := get_direction_name()
	$AnimatedSprite2D.play("punch_" + dir)
	await $AnimatedSprite2D.animation_finished  # await the SIGNAL, not call it
	
	$HitboxArea/CollisionShape2D.disabled = true
	
	is_attacking = false
	state = State.IDLE
	
func position_hitbox() -> void:
	var hitbox := $HitboxArea
	var offset := 30.0
	
	if abs(facing.x) > abs(facing.y):
		# Horizontal
		hitbox.position = Vector2(offset * sign(facing.x), 0)
	else:
		# Vertical
		hitbox.position = Vector2(0, offset * sign(facing.y))
		
func take_damage(amount: int) -> void:
	if is_invincible:
		return
	
	is_invincible = true
	var actual_damage: int = max(amount - stats.defense, 1)
	stats.current_health -= actual_damage
	HUD.update_hearts()
	flash()  # Add this
	
	if stats.current_health <= 0:
		die()
		return
	
	await get_tree().create_timer(invincibility_time).timeout
	is_invincible = false

func die() -> void:
	print("player died")
	# death handling will go here

func flash() -> void:
	var sprite := $AnimatedSprite2D
	var timer := get_tree().create_timer(invincibility_time)
	
	while timer.time_left > 0:
		sprite.modulate.a = 0.3
		await get_tree().create_timer(0.1).timeout
		sprite.modulate.a = 1.0
		await get_tree().create_timer(0.1).timeout
	
	sprite.modulate.a = 1.0

func enable_camera() -> void:
	$Camera2D.enabled = true
			
func disable_camera() -> void:
	$Camera2D.enabled = false

func ranged_attack() -> void:
	if not InventoryManager.equipped.has("ranged"):
		print("No ranged weapon equipped")
		return
	
	is_attacking = true
	state = State.ATTACK
	velocity = Vector2.ZERO
	
	var ranged_item: ItemData = InventoryManager.equipped["ranged"]
	
	# Play shoot animation
	var dir := get_direction_name()
	$AnimatedSprite2D.play("shoot_" + dir)
	
	# Spawn projectile
	var projectile = projectile_scene.instantiate()
	var move_dir: Vector2
	var spawn_offset: float
	
	if abs(facing.x) > abs(facing.y):
		move_dir = Vector2(sign(facing.x), 0)
		spawn_offset = 30.0
	else:
		move_dir = Vector2(0, sign(facing.y))
		spawn_offset = 45.0
	
	projectile.direction = move_dir
	projectile.damage = ranged_item.attack_bonus
	get_tree().current_scene.add_child(projectile)
	projectile.global_position = global_position + (move_dir * spawn_offset)
	
	# Wait for animation to finish
	await $AnimatedSprite2D.animation_finished
	
	is_attacking = false
	state = State.IDLE
