extends CharacterBody2D
var is_on = false
var goup_ttl = 0
var char = null
var gravity = 10.0
var speed = 75.0
var jump_speed = -300.0
var grabbed = false
var total_friction = 0.3
var friction = total_friction

func pushed(force, direction):
	pass

func _ready():
	add_to_group("interactuable")
	Global.emit(global_position, 15)

func _physics_process(delta):
	if !grabbed:
		if !is_on_floor():
			velocity.y += gravity
			
		velocity.x = lerp(velocity.x, 0.0, friction)
		if abs(velocity.x) <= 0.0:
			velocity.x = 0.0
			friction = total_friction
			
		move_and_slide()
		
		if is_on:
			goup_ttl -= 1 * delta
			if goup_ttl <= 0:
				$sprite.position = $up.position
				char.mega_jump()
				is_on = false
		else:
			$sprite.position = lerp($sprite.position, $down.position, 0.1)
			if $sprite.position.distance_to($down.position) <= 0.1:
				$sprite.position = $down.position
		
	else:
		$collider.set_deferred("disabled", true)
		$char_detect/collider.set_deferred("disabled", true)
		velocity.x = 0
		velocity.y = 0

func mega_jump():
	Global.play_sound(Global.JUMP_SFX)
	velocity.y = jump_speed * 2
	
func little_jump():
	Global.play_sound(Global.JUMP_SFX)
	velocity.y = jump_speed / 2
	
func droped(speed, direction):
	$collider.set_deferred("disabled", false)
	$char_detect/collider.set_deferred("disabled", false)
	velocity.y = jump_speed
	friction = 0.02
	pushed(speed * 2, direction)
	
func teleport(pos):
	global_position = pos
