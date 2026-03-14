extends Node

var stats: CharacterStats = preload("res://resources/player_stats.tres")
var facing: Vector2 = Vector2.DOWN
var is_dead: bool = false
var player_scene: PackedScene = preload("res://scenes/player/player.tscn")

func reset() -> void:
	is_dead = false
	stats.current_health = stats.max_health
	facing = Vector2.DOWN
