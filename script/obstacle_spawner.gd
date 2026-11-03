class_name ObstacleSpawner
extends Node
## Modul Procedural Generation (modular concept: Procedural Generation).
## Mengatur KAPAN, APA, dan DI MANA rintangan muncul.
## - Main hanya memanggil setup() dan scroll(), lalu mendengarkan 2 sinyal di bawah.
## - Spawner mendengarkan EventBus sendiri (game_ready, game_started, game_ended, score_changed).
## - Rintangan baru = scene yang root-nya extends Obstacle, lalu masukkan ke obstacle_scenes.
## - Acak terkendali: selisih tinggi antar pipa dibatasi supaya selalu bisa dilewati.
## - Seed: isi seed_value agar urutan pipa bisa diulang persis.

signal obstacle_hit
signal obstacle_scored

## Daftar scene rintangan yang boleh dimunculkan (mis. pipe.tscn, moving_pipe.tscn).
@export var obstacle_scenes: Array[PackedScene] = []
## Skor minimal agar scene di urutan yang sama mulai muncul. Contoh [0, 5].
@export var unlock_scores: Array[int] = [0, 5]
## Jarak muncul di luar layar sebelah kanan (px).
@export var spawn_margin: float = 100.0

@export_group("Difficulty")
## Jeda antar rintangan (detik): mulai -> minimum saat difficulty maksimal.
@export var start_interval: float = 1.5
@export var min_interval: float = 1.0
## Rentang naik-turun posisi celah dari tengah layar (px): mulai -> maksimum.
@export var start_range: float = 120.0
@export var max_range: float = 200.0
## Selisih tinggi maksimum antara dua pipa berurutan (px): mulai -> maksimum.
## Ini yang menjamin celah berikutnya selalu masih terjangkau burung.
@export var start_step: float = 150.0
@export var max_step: float = 250.0
## Skor di mana difficulty mencapai maksimum.
@export var ramp_score: int = 30

@export_group("Seed")
## 0 = acak berbeda tiap permainan. Isi angka lain untuk urutan pipa yang sama.
@export var seed_value: int = 0

var _screen_size: Vector2i = Vector2i(864, 768)
var _ground_height: int = 0
var _current_score: int = 0
var _last_y: float = 0.0
var _obstacles: Array[Obstacle] = []
var _rng := RandomNumberGenerator.new()
var _timer: Timer


func _ready() -> void:
	_timer = Timer.new()
	_timer.one_shot = true # jeda berubah tiap spawn, jadi dimulai ulang manual
	_timer.timeout.connect(_on_timer_timeout)
	add_child(_timer)

	EventBus.game_ready.connect(_on_game_ready)
	EventBus.game_started.connect(_on_game_started)
	EventBus.game_ended.connect(_on_game_ended)
	EventBus.score_changed.connect(_on_score_changed)


## Dipanggil Main sekali di _ready(), sebelum new_game().
func setup(screen_size: Vector2i, ground_height: int) -> void:
	_screen_size = screen_size
	_ground_height = ground_height


## Dipanggil Main tiap frame saat game berjalan.
func scroll(amount: float) -> void:
	for obstacle in _obstacles.duplicate():
		obstacle.move(amount)
		if obstacle.is_offscreen():
			_obstacles.erase(obstacle)
			obstacle.queue_free()


func clear() -> void:
	for obstacle in _obstacles:
		obstacle.queue_free()
	_obstacles.clear()


func spawn() -> void:
	var scene := _pick_scene()
	if scene == null:
		return
	var obstacle := scene.instantiate() as Obstacle
	obstacle.position.x = _screen_size.x + spawn_margin
	obstacle.position.y = _next_y()
	_last_y = obstacle.position.y
	obstacle.hit.connect(obstacle_hit.emit)
	obstacle.scored.connect(obstacle_scored.emit)
	add_child(obstacle)
	_obstacles.append(obstacle)


# ---------- Posisi (acak terkendali) ----------

func _center_y() -> float:
	return (_screen_size.y - _ground_height) / 2.0


## Acak, tapi dibatasi dua hal: rentang dari tengah layar dan selisih dari pipa sebelumnya.
func _next_y() -> float:
	var d := _difficulty()
	var range_y := lerpf(start_range, max_range, d)
	var step := lerpf(start_step, max_step, d)
	var low := maxf(_center_y() - range_y, _last_y - step)
	var high := minf(_center_y() + range_y, _last_y + step)
	return _rng.randf_range(low, high)


# ---------- Difficulty & pemilihan rintangan ----------

## 0.0 (mudah) sampai 1.0 (paling sulit), naik seiring skor.
func _difficulty() -> float:
	return clampf(float(_current_score) / float(maxi(ramp_score, 1)), 0.0, 1.0)


func _current_interval() -> float:
	return lerpf(start_interval, min_interval, _difficulty())


func _pick_scene() -> PackedScene:
	var available: Array[PackedScene] = []
	for i in obstacle_scenes.size():
		var unlock: int = unlock_scores[i] if i < unlock_scores.size() else 0
		if _current_score >= unlock:
			available.append(obstacle_scenes[i])
	if available.is_empty():
		return null
	return available[_rng.randi_range(0, available.size() - 1)]


# ---------- Seed ----------

func _reset_rng() -> void:
	if seed_value != 0:
		_rng.seed = seed_value
	else:
		_rng.randomize()
	print("ObstacleSpawner seed: ", _rng.seed) # salin angka ini ke seed_value untuk mengulang


# ---------- Reaksi terhadap EventBus ----------

func _on_game_ready() -> void:
	_timer.stop()
	clear()
	_current_score = 0
	_last_y = _center_y()
	_reset_rng()
	spawn() # rintangan pertama langsung ada, seperti sebelumnya


func _on_game_started() -> void:
	_timer.start(_current_interval())


func _on_game_ended(_s: int, _h: int, _n: bool) -> void:
	_timer.stop()


func _on_score_changed(score: int) -> void:
	_current_score = score


func _on_timer_timeout() -> void:
	spawn()
	_timer.start(_current_interval())
