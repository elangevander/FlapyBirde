extends Area2D

@export var bird_node : Node2D
@export var peluru_scene : PackedScene

var speed_y = 4.0
var is_tracking = true
var initial_position : Vector2
var time_passed = 0.0

var target_x_offset = 0.0
var move_x_timer = 0.0
var next_x_change_time = 3.0
var last_y_pos = 0.0

@onready var sprite = $AnimatedSprite2D

func _ready():
	initial_position = position
	last_y_pos = position.y
	_pick_new_x_offset()
	if sprite:
		sprite.play()

func reset():
	position = initial_position
	last_y_pos = position.y
	is_tracking = true
	time_passed = 0.0
	target_x_offset = 0.0
	move_x_timer = 0.0
	_pick_new_x_offset()
	get_tree().call_group("peluru", "queue_free")
	if sprite:
		sprite.play()

func _pick_new_x_offset():
	next_x_change_time = randf_range(3.0, 6.0)
	move_x_timer = 0.0
	AudioManager.play_sfx("swoosh")
	var rand_val = randf()
	if rand_val < 0.25:
		target_x_offset = randf_range(-180.0, -80.0)
	elif rand_val < 0.40:
		target_x_offset = randf_range(10.0, 40.0)
	else:
		target_x_offset = randf_range(-40.0, 20.0)

func _process(delta):
	var main_scene = get_tree().current_scene
	if main_scene and not main_scene.game_running:
		return

	time_passed += delta
	move_x_timer += delta

	if move_x_timer >= next_x_change_time:
		_pick_new_x_offset()

	var raw_x = initial_position.x + target_x_offset + sin(time_passed * 1.5) * 12.0
	var screen_width = get_viewport_rect().size.x
	var target_x = clampf(raw_x, 300.0, screen_width - 50.0)
	position.x = lerp(position.x, target_x, 1.5 * delta)

	# --- 2. Pergerakan Sumbu Y & Deteksi Pipa ---
	var y_hover = cos(time_passed * 3.0) * 10.0
	var target_y = initial_position.y
	var pipe_blocking = false
	var nearest_pipe_y = -1.0

	for pipe in get_tree().get_nodes_in_group("pipes"):
		if is_instance_valid(pipe):
			var dist_x = pipe.global_position.x - global_position.x
			if dist_x > -60.0 and dist_x < 120.0:
				nearest_pipe_y = pipe.global_position.y
				pipe_blocking = true
				break

	if pipe_blocking and nearest_pipe_y != -1.0:
		target_y = nearest_pipe_y
	elif is_tracking and is_instance_valid(bird_node):
		target_y = bird_node.global_position.y + y_hover

	var screen_height = get_viewport_rect().size.y
	target_y = clampf(target_y, 40.0, screen_height - 160.0)
	position.y = lerp(position.y, target_y, speed_y * delta)

	var y_velocity = (position.y - last_y_pos) / delta
	last_y_pos = position.y

	if sprite:
		var target_rotation = clampf(-y_velocity * 0.15, -20.0, 20.0)
		sprite.rotation_degrees = lerp(sprite.rotation_degrees, target_rotation, 10.0 * delta)

func tembak():
	if peluru_scene:
		AudioManager.play_sfx("pop", 0.1)
		var peluru = peluru_scene.instantiate()
		peluru.global_position = global_position + Vector2(-16, 0)
		peluru.add_to_group("peluru")
		get_parent().add_child(peluru)

		var tween = create_tween()
		tween.tween_property(self, "scale", Vector2(1.2, 0.8), 0.05)
		tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.1)

func _on_timer_timeout():
	var main_scene = get_tree().current_scene
	if main_scene and not main_scene.game_running:
		return

	for pipe in get_tree().get_nodes_in_group("pipes"):
		if is_instance_valid(pipe):
			var dist_x = pipe.global_position.x - global_position.x
			if dist_x > 0 and dist_x < 150:
				return

	is_tracking = false
	tembak()
	await get_tree().create_timer(0.4).timeout
	is_tracking = true
