extends Node2D
var recording = false
var current_record = []
var player_o = load("res://scenes/player.tscn")

func _ready() -> void:
	Global.TIME_LEFT = Global.TOTAL_TIME_LEFT
	calc_time()
	current_record = []
	Global.recording_obj = self
	var idx = 0
	if Global.RECORDINGS.size() > 0:
		for r in Global.RECORDINGS:
			var p = player_o.instantiate()
			p.global_position = $"../Player".global_position
			p.recorded = r
			p.set_init(Global.RECORDINGS_PLAYER[idx])
			add_child(p)
			idx += 1

func end_recording():
	recording = false
	Global.RECORDINGS.append(current_record)
	Global.RECORDINGS_PLAYER.append(Global.player_obj.prefix)
	Global.RECORDINGS_IDX += 1
	Global.playing = false
	get_tree().reload_current_scene()
	
func debug_record():
	if !recording:
		#if Input.is_action_just_pressed("debug_record"):
		recording = true
		$Timer.start()
	else:
		#if Input.is_action_just_pressed("debug_record"):
		end_recording()

func _physics_process(delta: float) -> void:
	if recording:
		var jump = false
		var left = false
		var right = false
		var up = false
		var down = false
		var shoot = false
		
		if Input.is_action_just_pressed("jump"):
			jump = true
			
		if Input.is_action_pressed("shoot"):
			shoot = true
			
		if Input.is_action_pressed("left"):
			left = true
			
		elif Input.is_action_pressed("right"):
			right = true
		
		if Input.is_action_pressed("up"):
			up = true

		elif Input.is_action_pressed("down"):
			down = true
		
		var frame = {"shoot": shoot, "jump": jump, "up": up, "down": down, "left": left, "right": right}
		current_record.append(frame)

func calc_time():
	Global.minutes = int(Global.TIME_LEFT / 60)
	Global.seconds = int(Global.TIME_LEFT % 60)
	$time_elpased.text = "%02d:%02d" % [Global.minutes, Global.seconds]

func _on_timer_timeout() -> void:
	Global.TIME_LEFT -= 1
	if Global.TIME_LEFT <= 0:
		end_recording()
		
	calc_time()
