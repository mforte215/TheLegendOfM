extends Node

var stats: CharacterStats = preload("res://resources/player_stats.tres")
var facing: Vector2 = Vector2.DOWN
var is_dead: bool = false
var player_scene: PackedScene = preload("res://scenes/player/player.tscn")
var coins: int = 0
var max_coins = 999

signal coins_changed

func add_coins(amount: int) -> void:
	coins = min(coins + amount, max_coins)
	coins_changed.emit()

func remove_coins(amount: int) -> bool:
	if coins >= amount:
		coins -= amount
		coins_changed.emit()
		return true
	return false


func reset() -> void:
	is_dead = false
	stats.current_health = stats.max_health
	facing = Vector2.DOWN
