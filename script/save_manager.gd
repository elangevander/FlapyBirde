extends Node

const SAVE_PATH := "user://savegame.cfg"
var high_score: int = 0

func _ready() -> void:
	load_data()

func save_data() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("game", "high_score", high_score)
	cfg.save(SAVE_PATH)

func load_data()->void:
	var cfg := ConfigFile.new()
	if cfg.load(SAVE_PATH) == OK:
		high_score = cfg.get_value("game", "high_score", 0)
		
func submit_score(score: int) -> void:
	if score > high_score:
		high_score = score
		save_data()

 

	
