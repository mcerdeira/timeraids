extends CharacterBody2D
var SPEED = 275.0
var JUMP_VELOCITY = -500.0
var shoot_delay = 0.0
var shoot_delay_total = 0.0
var bullet_obj = preload("res://scenes/bullet.tscn")
var explosion_obj = preload("res://scenes/explosion.tscn")
var jump_ttl_total = 0.5
var jump_ttl = 0.0
var jumping = false
var canjump = true
var moving = false
var scale_x = 1.0
var scale_y = 1.0
var dont_move = false
var direction = "R"
var direction_shoot = "R"
var frame = 0
var recorded = null
var playing = false
var prefix = "unknown"
var gun_sprite : AnimatedSprite2D = null
var gun_shoot_point : Marker2D = null
var bullet_ttl = 1.0
var is_absorved = false

func mega_jump():
	Global.emit(global_position, 2)
	Global.play_sound(Global.SPRING_SFX)
	velocity.y = JUMP_VELOCITY * 2

func _ready() -> void:
	add_to_group("players")
	set_init(prefix)
	
func absorved():
	is_absorved = true
	
func set_init(_prefix):
	prefix = _prefix
	guns_hide()
	
	if prefix == "":
		bullet_ttl = 1.0
		gun_sprite = $pistol
		gun_shoot_point = $pistol/point
		shoot_delay_total = 0.4
	elif prefix == "machine":
		bullet_ttl = 0.2
		gun_sprite = $machine
		gun_shoot_point = $machine/point
		shoot_delay_total = 0.1
	elif prefix == "bomb":
		SPEED = 375.0
		bullet_ttl = 0.0
		gun_sprite = $dummy
		gun_shoot_point = null
		shoot_delay_total = 0.0
	elif prefix == "moth":
		SPEED = 300.0
		bullet_ttl = 0.2
		gun_sprite = $dummy
		gun_shoot_point = null
		shoot_delay_total = 0.0
	elif prefix == "rock":
		SPEED = 175.0
		bullet_ttl = 0.2
		gun_sprite = $dummy
		gun_shoot_point = null
		shoot_delay_total = 0.0
	elif prefix == "unknown":
		bullet_ttl = 0.2
		gun_sprite = $dummy
		gun_shoot_point = null
		shoot_delay_total = 0.0
		
	gun_sprite.visible = true
	$sprite.play(prefix + "_idle")
	if recorded == null:
		Global.player_obj = self
		
func guns_hide():
	$pistol.visible = false
	$machine.visible = false

func _physics_process(delta: float) -> void:
	if Global.WIN:
		if is_absorved:
			visible = false
			guns_hide()
			return
	
	if shoot_delay > 0:
		shoot_delay -= 1 * delta
	
	if not is_on_floor():
		velocity += get_gravity() * delta
		
	if jumping and prefix == "moth":
		jump_ttl -= 1 * delta
		if jump_ttl <= 0:
			canjump = true
			jumping = false
			scale_x = 3.8
			scale_y = 0.1
		
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
		if Global.playing:
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
		if Global.playing:
			jump = Input.is_action_just_pressed("jump")
			left = Input.is_action_pressed("left")
			right = Input.is_action_pressed("right")
			up = Input.is_action_pressed("up")
			down = Input.is_action_pressed("down")
			shoot = Input.is_action_pressed("shoot")
		
	if !dont_move and jump and (is_on_floor() or (canjump and prefix == "" or prefix == "moth")):
		if !is_on_floor():
			canjump = false
		
		$shield.visible = false
		jump_ttl = jump_ttl_total
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
		$shield.visible = false
		direction_shoot = "L"
		direction = "L"
		velocity.x = -1 * SPEED
		moving = true
		$sprite.flip_h = true
		gun_sprite.scale.x = -1
	elif !dont_move and right:
		$shield.visible = false
		direction_shoot = "R"
		direction = "R"
		velocity.x = 1 * SPEED
		moving = true
		$sprite.flip_h = false
		gun_sprite.scale.x = 1
	else:
		velocity.x = 0
		
	if !dont_move and up and right:
		direction_shoot = "RU"
		gun_sprite.rotation_degrees = 313
	elif !dont_move and up and left:
		direction_shoot = "LU"
		gun_sprite.rotation_degrees = 46
	elif !dont_move and up:
		direction_shoot = "U"
		if $sprite.flip_h:
			gun_sprite.rotation_degrees = -270
		else:
			gun_sprite.rotation_degrees = 270
	elif !dont_move and down:
		direction_shoot = "D"
		if $sprite.flip_h:
			gun_sprite.rotation_degrees = -90
		else:
			gun_sprite.rotation_degrees = 90
			
	else:
		gun_sprite.rotation_degrees = 0
		if gun_sprite.scale.x == -1:
			direction_shoot = "L"
		else:
			direction_shoot = "R"
	
	if!dont_move and shoot:
		shoot()
		
	if !Global.GAMEOVER:
		if moving:
			$sprite.play(prefix + "_running")
		else:
			$sprite.play(prefix + "_idle")

		move_and_slide()
		
		var slide_col = get_slide_collision_count()
		var push_something = false
		for i in slide_col:
			var c = get_slide_collision(i)
			var col = c.get_collider() 
			var normal = c.get_normal()
			if col.is_in_group("interactuable") and normal.y == 0:
				push_something = true
				col.pushed(SPEED, direction)
		
func shoot():
	if prefix == "rock":
		$shield.visible = true
	if prefix == "bomb":
		Global.shaker_obj.shake(10, 3)
		var exp = explosion_obj.instantiate()
		exp.global_position = global_position
		get_parent().add_child(exp)
		visible = false
		dont_move = true
	else:
		if gun_shoot_point == null:
			return
		
		if shoot_delay <= 0:
			Global.shaker_obj.shake(3.0, 1.0)
			shoot_delay = shoot_delay_total
			var buff = 0.0
			var dir = 0.0

			var bullet = bullet_obj.instantiate()
			bullet.global_position = gun_shoot_point.global_position
			bullet.rotation_degrees = gun_sprite.rotation_degrees
			bullet.ttl = bullet_ttl
			if direction_shoot == "R":
				dir = 1.0
				bullet.direction = Vector2.RIGHT
			if direction_shoot == "L":
				dir = -1.0
				bullet.direction = Vector2.LEFT
			if direction_shoot == "U":
				dir = 0.0
				bullet.direction = Vector2.UP
			if direction_shoot == "D":
				dir = 0.0
				bullet.direction = Vector2.DOWN
			if direction_shoot == "RU":
				dir = 1.0
				bullet.direction = Vector2.from_angle(deg_to_rad(bullet.rotation_degrees))
			if direction_shoot == "LU":
				dir = -1.0
				bullet.direction =  Vector2.from_angle(deg_to_rad(bullet.rotation_degrees - 180))
			
			get_parent().add_child(bullet)
			
			if moving:
				buff = 50 * dir
