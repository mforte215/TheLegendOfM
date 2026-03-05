extends Area2D

signal hurt(amount: int)

func _ready() -> void:
	area_entered.connect(_on_area_entered)
	monitoring = true
	monitorable = true

func _on_area_entered(area: Node) -> void:
	print("hurtbox detected: ", area.name)
	if area.is_in_group("hitbox"):
		hurt.emit(area.damage)
