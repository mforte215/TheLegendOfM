extends Area2D

func _ready() -> void:
	area_entered.connect(_on_area_entered)
	body_entered.connect(_on_body_entered)
	print("hurtbox ready 1100")

func _on_area_entered(area: Node) -> void:
	print("area entered hurtbox: ", area.name)

func _on_body_entered(body: Node) -> void:
	print("body entered hurtbox: ", body.name)
