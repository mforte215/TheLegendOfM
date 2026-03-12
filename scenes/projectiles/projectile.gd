extends Area2D

var direction: Vector2 = Vector2.ZERO
var speed: float = 500.0
var damage: int = 1
var max_range: float = 500.0
var distance_traveled: float = 0.0

func _ready() -> void:
	collision_layer = 8
	collision_mask = 4
	add_to_group("hitbox")
	area_entered.connect(_on_area_entered)
	z_index = 10
	print("Sprite visible: ", $Sprite2D.visible)
	print("Sprite texture: ", $Sprite2D.texture)
	print("Sprite scale: ", $Sprite2D.scale)
	print("Projectile visible: ", visible)
	print("Projectile z_index: ", z_index)
	# If no texture, draw a white circle so we can see it
	if $Sprite2D.texture == null:
		var img := Image.create(8, 8, false, Image.FORMAT_RGBA8)
		img.fill(Color.WHITE)
		$Sprite2D.texture = ImageTexture.create_from_image(img)
	
	print("Projectile spawned at ", global_position, " direction: ", direction)
	if direction == Vector2.LEFT:
		$Sprite2D.flip_h = true
	elif direction == Vector2.UP:
		rotation_degrees = -90
	elif direction == Vector2.DOWN:
		rotation_degrees = 90
func _physics_process(delta: float) -> void:
	var movement := direction * speed * delta
	position += movement
	distance_traveled += movement.length()
	
	if distance_traveled >= max_range:
		queue_free()

func _on_area_entered(area: Node) -> void:
	if area.is_in_group("hurtbox") and area.owner != null:
		# Don't hit the player
		if area.owner.is_in_group("player"):
			return
		area.hurt.emit(damage)
		queue_free()
