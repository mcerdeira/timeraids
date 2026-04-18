extends Node2D
@export var char = 0

func _ready() -> void:
	$sprite.frame = char
