extends AnimatedSprite2D

@onready var light := $PointLight2D

func _ready() -> void:
	play("burn")
	flicker()

func flicker() -> void:
	while true:
		var target_energy := randf_range(0.6, 1.0)
		var duration := randf_range(0.05, 0.15)
		
		var tween := create_tween()
		tween.tween_property(light, "energy", target_energy, duration)
		await tween.finished
