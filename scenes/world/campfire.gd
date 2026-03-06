extends AnimatedSprite2D
@onready var light := $PointLight2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	play("burn")
	flicker()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func flicker() -> void:
	var tween := create_tween()
	tween.set_loops()
	
	# Randomize each flicker cycle
	var target_energy := randf_range(0.8, 1.2)
	var duration := randf_range(0.7, 0.9)
	
	tween.tween_property(light, "energy", target_energy, duration)
	tween.tween_callback(flicker)
