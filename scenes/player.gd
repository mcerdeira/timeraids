extends CharacterBody2D
const SPEED = 275.0
const JUMP_VELOCITY = -500.0
var jumping = false
var canjump = true
var moving = false
var scale_x = 1.0
var scale_y = 1.0
var dont_move = false
var direction_shoot = "R"
var frame = 0
var recorded = null
var playing = false

func _ready() -> void:
	add_to_group("players")
	Global.player_obj = self

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
		
	if jumping and is_on_floor():
		canjump = true
		jumping = false
		scale_x = 3.8
		scale_y = 0.1
		
	moving = false
	
	var jump = false
	var left = false
	var right = false
	var up = false
	var down = false
	var shoot = false
	
	if recorded:
		if playing:
			if frame < recorded.size():
				var _Input = recorded[frame]
				jump = _Input.jump
				left = _Input.left
				right = _Input.right
				up = _Input.up
				down = _Input.down
				shoot = _Input.shoot
				
				frame += 1
		else:
			if Input.is_action_just_pressed("debug_record"):
				playing = true
	else:
		if playing:
			jump = Input.is_action_just_pressed("jump")
			left = Input.is_action_pressed("left")
			right = Input.is_action_pressed("right")
			up = Input.is_action_pressed("up")
			down = Input.is_action_pressed("down")
			shoot = Input.is_action_pressed("shoot")
		else:
			if Input.is_action_just_pressed("debug_record"):
				playing = true
		
	if !dont_move and jump and (is_on_floor() or (canjump)):
		if !is_on_floor():
			canjump = false
		
		velocity.y = JUMP_VELOCITY
		scale_x = 0.1
		scale_y = 3.1
		jumping = true
		
	if scale_x > 1.0:
		scale_x = lerp(scale_x, 1.0, 0.3)
		
	if scale_x < 1.0:
		scale_x = lerp(scale_x, 1.0, 0.1)
		
	if scale_y > 1.0:
		scale_y = lerp(scale_y, 1.0, 0.1)
		
	if scale_y < 1.0:
		scale_y = lerp(scale_y, 1.0, 0.1)
		
	$sprite.scale.x = lerp($sprite.scale.x, scale_x, 0.1)
	$sprite.scale.y = lerp($sprite.scale.y, scale_y, 0.1)
		
	if !dont_move and left:
		direction_shoot = "L"
		velocity.x = -1 * SPEED
		moving = true
		$sprite.flip_h = true
		$gun.scale.x = -1
	elif !dont_move and right:
		direction_shoot = "R"
		velocity.x = 1 * SPEED
		moving = true
		$sprite.flip_h = false
		$gun.scale.x = 1
	else:
		velocity.x = 0
		
	if !dont_move and up and right:
		direction_shoot = "RU"
		$gun.rotation_degrees = 313
	elif !dont_move and up and left:
		direction_shoot = "LU"
		$gun.rotation_degrees = 46
	elif !dont_move and up:
		direction_shoot = "U"
		if $sprite.flip_h:
			$gun.rotation_degrees = -270
		else:
			$gun.rotation_degrees = 270
	elif !dont_move and down:
		direction_shoot = "D"
		if $sprite.flip_h:
			$gun.rotation_degrees = -90
		else:
			$gun.rotation_degrees = 90
			
	else:
		$gun.rotation_degrees = 0
		if $gun.scale.x == -1:
			direction_shoot = "L"
		else:
			direction_shoot = "R"
	
	if!dont_move and shoot:
		shoot()
		
	if !Global.GAMEOVER:
		if moving:
			$sprite.play("running")
		else:
			$sprite.play("idle")

		move_and_slide()

func shoot():
	pass
