extends Node2D
@export var char = 0

func _ready() -> void:
	if char == -1:
		$sprite.animation = "unknown"
	else:
		$sprite.frame = char
