extends Resource
class_name CharacterStats

@export var character_name: String = ""
@export var max_health: int = 6
@export var current_health: int = 6
@export var attack: int = 1
@export var defense: int = 0
@export var speed: float = 90.0
@export var level: int = 1
@export var experience: int = 0
@export var experience_to_next_level: int = 100
@export var inventory: Inventory
