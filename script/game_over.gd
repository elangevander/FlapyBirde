extends CanvasLayer

signal restart

# Label ini opsional: kalau node "HighScoreLabel" belum dibuat, script tetap jalan.
@onready var high_score_label: Label = get_node_or_null("HighScoreLabel") as Label

var _base_y: Dictionary = {} # posisi y asli tiap Control


func _ready() -> void:
	for child in get_children():
		if child is Control:
			_base_y[child] = child.position.y


## Menampilkan panel game over dengan animasi muncul bergantian.
func show_animated(score: int, high_score: int, is_new_best: bool) -> void:
	if high_score_label:
		if is_new_best:
			high_score_label.text = "NEW BEST: %d" % high_score
		else:
			high_score_label.text = "SCORE: %d   BEST: %d" % [score, high_score]
	show()

	var delay := 0.0
	for child in _base_y:
		var control: Control = child
		control.modulate.a = 0.0
		control.position.y = _base_y[control] + 60.0
		var tw := create_tween().set_parallel(true)
		tw.tween_property(control, "modulate:a", 1.0, 0.35).set_delay(delay)
		tw.tween_property(control, "position:y", _base_y[control], 0.35) \
			.set_delay(delay).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		delay += 0.12


func _on_restart_button_pressed() -> void:
	restart.emit()


func _on_menu_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scene/main_menu.tscn")
