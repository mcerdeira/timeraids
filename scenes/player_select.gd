extends Node2D

@export var radius_x: float = 100.0
@export var radius_y: float = 20.0
@export var min_scale: float = 0.55
@export var tween_time: float = 0.18

var chars = []
var base_angle: float = 0.0
var step_angle: float
var tween: Tween
var selected_index = 0

func _ready():
	visible = true
	chars = $Chars.get_children()
	step_angle = TAU / chars.size()
	update_layout(true)
	set_pname()
	
func set_pname():
	if visible:
		var selected = chars[selected_index]
		$lbl_name.text = Global.character_names[selected.char]
		Global.player_obj.set_init(Global.character_ids[selected.char])

func _unhandled_input(event):
	if visible:
		if event.is_action_pressed("right"):
			rotate_selection(-1)
		elif event.is_action_pressed("left"):
			rotate_selection(1)

func rotate_selection(dir: int):
	if visible:
		if chars.is_empty():
			return
		base_angle += step_angle * dir
		selected_index = wrapi(selected_index + (dir *-1), 0, chars.size())  # 👈 clave
		set_pname()
		update_layout(false)

func update_layout(instant: bool):
	if visible:
		if tween:
			tween.kill()

		tween = create_tween()
		tween.set_trans(Tween.TRANS_SINE)
		tween.set_ease(Tween.EASE_OUT)
		tween.set_parallel(true) 

		for i in range(chars.size()):
			var node = chars[i]
			var angle = base_angle + i * step_angle

			var x = sin(angle) * radius_x
			var y = cos(angle) * radius_y

			var target_pos = Vector2(x, y)
			var depth = (y + radius_y) / (2.0 * radius_y)

			var s = lerp(min_scale, 1.0, depth)
			var target_scale = Vector2(s, s)

			node.z_index = int(depth * 100)
			node.modulate.a = lerp(0.4, 1.0, depth)

			if instant:
				node.position = target_pos
				node.scale = target_scale
			else:
				tween.tween_property(node, "position", target_pos, tween_time)
				tween.tween_property(node, "scale", target_scale, tween_time)

func _on_btn_select_pressed() -> void:
	visible = false
	Global.playing = true
	Global.recording_obj.debug_record()
	queue_free()
