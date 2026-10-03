extends Area2D

signal hit
signal scored

func _ready() -> void:
	add_to_group("pipes")
	
func _on_body_entered(body: Node2D) -> void:
	hit.emit()

func _on_score_area_body_entered(body: Node2D) -> void:
	scored.emit()
