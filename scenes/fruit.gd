extends Area2D
var is_on = true
var speed = 89
var rotate_dir = 1
var rotate_ttl_total = 0.3
var rotate_ttl = rotate_ttl_total

func _ready():
	Global.TOTAL_FRUITS += 1

func _physics_process(delta):
	if is_on:
		rotate_ttl -= 1 * delta
		if rotate_ttl <= 0:
			rotate_ttl = rotate_ttl_total
			rotate_dir *= -1
		
		$sprite.rotation_degrees += (speed * rotate_dir) * delta
	else:
		$sprite.rotation_degrees = 0

func _on_animation_player_animation_finished(anim_name):
	Global.emit(global_position, 1)
	queue_free()

func _on_body_entered(body: Node2D) -> void:
	if is_on and body.is_in_group("players"):
		is_on = false
		Global.play_sound(Global.BITE_SFX)
		Global.FRUITS += 1
		if Global.FRUITS >= Global.TOTAL_FRUITS:
			Global.PORTAL.set_on()
		$AnimationPlayer.play("new_animation")
