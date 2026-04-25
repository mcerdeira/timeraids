extends AnimatedSprite2D

func _ready():
	speed_scale = Global.pick_random([1, 1.5, 2])

func _on_timer_timeout():
	visible = Global.pick_random([true, false])
	$Timer.wait_time = Global.pick_random([0.1, 0.5, 0.2])
