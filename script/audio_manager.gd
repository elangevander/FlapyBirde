extends Node

const SOUNDS := {
	"flap": "res://audio/flap.wav",
	"score": "res://audio/score.wav",
	"hit": "res://audio/hit.wav",
}
const MUSIC_PATH := "res://audio/music.wav"

var players := {}
var music_player := AudioStreamPlayer.new()

func _ready() -> void:
	for key in SOUNDS:
		var path: String = SOUNDS[key]
		if ResourceLoader.exists(path):
			var p := AudioStreamPlayer.new()
			p.stream = load(path)
			add_child(p)
			players[key] = p
	if ResourceLoader.exists(MUSIC_PATH):
		music_player.stream = load(MUSIC_PATH)
		music_player.volume_db = -10
		add_child(music_player)
		music_player.play()

func  play(sound_name: String) -> void:
	if players.has(sound_name):
		players[sound_name].play()
		
		
