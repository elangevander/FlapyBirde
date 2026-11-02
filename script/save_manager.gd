extends Node
## Autoload "SaveManager" (modular concept: Save & Load).
## Menyimpan data permanen (high score, mute) ke user://flappy_save.cfg.

signal high_score_changed(new_value: int)

const SAVE_PATH := "user://flappy_save.cfg"
const SECTION := "game"

# Semua data yang disimpan ada di satu tempat; tambah key baru di sini.
var _data: Dictionary = {
	"high_score": 0,
	"muted": false,
}

var high_score: int:
	get:
		return _data["high_score"]


func _ready() -> void:
	load_data()


func load_data() -> void:
	var cfg := ConfigFile.new()
	if cfg.load(SAVE_PATH) != OK:
		return # belum ada file save -> pakai nilai default
	for key in _data:
		_data[key] = cfg.get_value(SECTION, key, _data[key])


func save_data() -> void:
	var cfg := ConfigFile.new()
	for key in _data:
		cfg.set_value(SECTION, key, _data[key])
	var err := cfg.save(SAVE_PATH)
	if err != OK:
		push_warning("SaveManager: gagal menyimpan (error %d)" % err)


func get_value(key: String, default: Variant = null) -> Variant:
	return _data.get(key, default)


func set_value(key: String, value: Variant) -> void:
	_data[key] = value
	save_data()


## Mengembalikan true kalau skor ini adalah rekor baru.
func submit_score(score: int) -> bool:
	if score <= high_score:
		return false
	_data["high_score"] = score
	save_data()
	high_score_changed.emit(score)
	return true


func reset_data() -> void:
	_data["high_score"] = 0
	save_data()
