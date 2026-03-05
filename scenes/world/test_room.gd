extends Node2D

func _ready() -> void:
	Player.place_at($PlayerSpawn.global_position)
	
