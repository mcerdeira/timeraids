extends Area2D
var is_on = false
var speed = 120

func _ready():
	$sprite.modulate.a = 0.1
	Global.PORTAL = self
	$sprite.play()
	$AnimationPlayer.play("new_animation")
	
func set_on():
	$sprite.modulate.a = 1
	is_on = true
	$sprite.frame = 1
	speed = 200

func _process(delta):
	if $player_fake.visible:
		$player_fake.rotation_degrees += 560 * delta
		$player_fake.scale.x = lerp($player_fake.scale.x, 0.0, 0.009)
		$player_fake.scale.y = $player_fake.scale.x 
	
	$sprite.rotation_degrees += speed * delta
	if !is_on and Global.WIN:
		if randi() % 50 == 0:
			Global.emit(global_position, 1)

func _on_body_entered(body: Node2D) -> void:
	if is_on and body.is_in_group("players"):
		is_on = false
		speed = 500
		Global.play_sound(Global.PORTAL_SFX)
		Global.WIN = true
		$rays.rotation_degrees = randi() % 360
		$rays.visible = true
		$AnimationPlayer2.play("new_animation")
		$player_fake.visible = true
		$player_fake.animation = body.prefix + "_idle"
		body.global_position = global_position
		body.absorved()
