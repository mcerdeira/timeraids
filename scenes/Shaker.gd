extends Node2D
@export var camera : Camera2D = null
var camera_shake_intensity = 0.0
var camera_shake_duration = 0.0


enum Type {Random, Sine, Noise}

func _ready():
	Global.shaker_obj = self
	
func shake(intensity, duration, type = Type.Random, _global_position = null):
	if intensity > camera_shake_intensity and duration > camera_shake_duration:
		camera_shake_intensity = intensity
		camera_shake_duration = duration

func _physics_process(delta):
	if camera == null:
		return
	
	if camera_shake_duration <= 0:
		# Reset the camera when the shaking is done
		camera.offset = Vector2(0, 0)
		camera_shake_intensity = 0.0
		camera_shake_duration = 0.0
		return

	camera_shake_duration = camera_shake_duration - delta
	
	# Shake it
	var offset = Vector2.ZERO
		
	offset = Vector2(randf(), randf()) * camera_shake_intensity
	
	offset = offset
	
	camera.offset = offset
