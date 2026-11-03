extends Node

var game_running : bool
var game_over : bool
var scroll
var score
var SCROLL_SPEED : int = 4
var screen_size : Vector2i
var ground_height : int


func _ready():
	screen_size = get_window().size
	ground_height = $Ground.get_node("Sprite2D").texture.get_height()

	# Modul Procedural Generation
	$ObstacleSpawner.setup(screen_size, ground_height)
	$ObstacleSpawner.obstacle_hit.connect(bird_hit)
	$ObstacleSpawner.obstacle_scored.connect(scored)

	# Aman walau sinyal restart sudah disambung lewat editor
	if not $GameOver.restart.is_connected(_on_game_over_restart):
		$GameOver.restart.connect(_on_game_over_restart)

	new_game()


func new_game():
	game_running = false
	game_over = false
	score = 0
	scroll = 0
	$Ground.position.x = 0
	EventBus.game_ready.emit()
	$Bird.reset()


func _input(event):
	if event is InputEventKey and event.pressed and event.keycode == KEY_M:
		AudioManager.toggle_mute()
	if game_over == false:
		if event is InputEventMouseButton:
			if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
				if game_running == false:
					start_game()
				else:
					if $Bird.flying:
						$Bird.flap()
						check_top()


func start_game():
	AudioManager.play_music()
	game_running = true
	$Bird.flying = true
	EventBus.game_started.emit()
	$Bird.flap()


func _process(_delta):
	if game_running:
		scroll += SCROLL_SPEED
		if scroll >= screen_size.x:
			scroll = 0
		$Ground.position.x = -scroll
		$ObstacleSpawner.scroll(SCROLL_SPEED)


func scored():
	score += 1
	AudioManager.play_sfx("score")
	EventBus.score_changed.emit(score)


func check_top():
	if $Bird.position.y < 0:
		$Bird.falling = true
		stop_game()


func stop_game():
	if game_over:
		return
	var is_new_best := SaveManager.submit_score(score)
	AudioManager.play_sfx("hit")
	AudioManager.stop_music()
	Fx.flash($Bird/AnimatedSprite2D)
	$Bird.flying = false
	game_running = false
	game_over = true
	EventBus.game_ended.emit(score, SaveManager.high_score, is_new_best)


func bird_hit():
	if game_over:
		return
	$Bird.falling = true
	stop_game()


func _on_ground_hit():
	$Bird.falling = false
	stop_game()


func _on_game_over_restart() -> void:
	new_game()
