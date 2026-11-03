extends CanvasLayer
## HUD (modular concept: UI Screen).
## Menampilkan skor dan teks "klik untuk memulai".
## Tidak tahu apa pun soal burung/pipa: hanya mendengarkan EventBus.

@onready var score_label: Label = %ScoreLabel
@onready var start_label: Label = %StartLabel


func _ready() -> void:
	EventBus.game_ready.connect(_on_game_ready)
	EventBus.game_started.connect(_on_game_started)
	EventBus.score_changed.connect(_on_score_changed)

func _on_game_ready() -> void:
	score_label.text = "SCORE: 0"
	start_label.show()
	Fx.pulse(start_label)


func _on_game_started() -> void:
	print("HUD: game_started diterima")
	start_label.hide()


func _on_score_changed(score: int) -> void:
	score_label.text = "SCORE: " + str(score)
	Fx.pop(score_label)
