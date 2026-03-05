extends Node2D

func _ready() -> void:
	$AreaOne.area_entered.connect(func(area): print("AreaOne detected: ", area.name))
	$AreaTwo.area_entered.connect(func(area): print("AreaTwo detected: ", area.name))
	print("test scene ready")
