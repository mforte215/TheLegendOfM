extends Area2D

signal hurt(amount: int)

func _ready() -> void:
	add_to_group("hurtbox")
	area_entered.connect(_on_area_entered)
	monitoring = true
	monitorable = true

func _on_area_entered(area: Node) -> void:
	if area.is_in_group("hitbox"):
		# Don't let the player's own projectiles hurt them
		if owner and owner.is_in_group("player") and area.get("damage") != null:
			# Check if this hitbox belongs to the player (melee) or was spawned by the player (projectile)
			if area.owner == owner:
				return
			# Player projectiles have no owner set to the player, so check collision mask
			if area.collision_mask == 4:  # mask 4 = targets enemies, so it's a player projectile
				return
		hurt.emit(area.damage)
