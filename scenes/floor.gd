extends StaticBody2D
var where = null
@export var type = "red_door"

func _ready():
	add_to_group(type)
	$sprite.animation = type
	
func _physics_process(delta):
	if where:
		$sprite.position = lerp($sprite.position, where.position, 0.1)
		if $sprite.position.distance_to(where.position) <= 0.1:
			$sprite.position = where.position
			where = null
		$collision.position = $sprite.position

func open():
	Global.emit(global_position, 1)
	where = $down

func close():
	Global.emit(global_position, 1)
	where = $up
