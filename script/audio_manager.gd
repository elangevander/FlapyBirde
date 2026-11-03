extends Node
## Autoload "AudioManager" (modular concept: Audio System).
## Pasang SETELAH SaveManager di daftar Autoload.
## Kalau file audio belum ada, game tetap jalan (hanya muncul warning).

const SFX_PATHS := {
	"flap": "res://audio/flap.wav",
	"score": "res://audio/score.wav",
	"hit": "res://audio/hit.wav",
	"click" : "res://audio/click.wav"
}
const MUSIC_PATH := "res://audio/music.wav"
const POOL_SIZE := 6 # jumlah SFX yang bisa bunyi bersamaan

var muted: bool = false

var _sfx: Dictionary = {}
var _pool: Array[AudioStreamPlayer] = []
var _music: AudioStreamPlayer


func _ready() -> void:
	for i in POOL_SIZE:
		var player := AudioStreamPlayer.new()
		add_child(player)
		_pool.append(player)

	_music = AudioStreamPlayer.new()
	_music.volume_db = -8.0
	add_child(_music)

	for key in SFX_PATHS:
		var path: String = SFX_PATHS[key]
		if ResourceLoader.exists(path):
			_sfx[key] = load(path)
		else:
			push_warning("AudioManager: file tidak ditemukan: " + path)

	muted = SaveManager.get_value("muted", false)
	_apply_mute()


func play_sfx(sfx_name: String, pitch_variation: float = 0.0) -> void:
	if not _sfx.has(sfx_name):
		return
	for player in _pool:
		if not player.playing:
			player.stream = _sfx[sfx_name]
			player.pitch_scale = 1.0 + randf_range(-pitch_variation, pitch_variation)
			player.play()
			return


func play_music() -> void:
	if _music.playing or not ResourceLoader.exists(MUSIC_PATH):
		return
	var stream: AudioStream = load(MUSIC_PATH)
	if "loop" in stream:
		stream.loop = true
	_music.stream = stream
	_music.play()


func stop_music() -> void:
	_music.stop()


func toggle_mute() -> void:
	muted = not muted
	_apply_mute()
	SaveManager.set_value("muted", muted)


func _apply_mute() -> void:
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), muted)
