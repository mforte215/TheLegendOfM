extends Area2D

var direction: Vector2 = Vector2.ZERO
var speed: float = 10.0
var damage: int = 1
var max_range: float = 400.0
var distance_traveled: float = 0.0
var hit := false
func _ready() -> void:
	collision_layer = 8   # triggers
	collision_mask = 2    # player
	add_to_group("hitbox")
	area_entered.connect(_on_area_entered)
	z_index = 10
	
	# Rotate sprite to match direction
	if direction == Vector2.LEFT:
		$Sprite2D.flip_h = true
	elif direction == Vector2.UP:
		rotation_degrees = -90
	elif direction == Vector2.DOWN:
		rotation_degrees = 90

func _physics_process(delta: float) -> void:
	if hit:
		return
	var movement := direction * speed * delta
	position += movement
	distance_traveled += movement.length()
	
	if distance_traveled >= max_range:
		queue_free()

func _on_area_entered(area: Node) -> void:
	print("ENEMY PROJECTILE HIT: ", area.name, " owner: ", area.owner)
	if hit:
		return
	if area.is_in_group("hurtbox") and area.owner != null:
		if not area.owner.is_in_group("player"):
			return
		hit = true
		area.hurt.emit(damage)
		queue_free()
