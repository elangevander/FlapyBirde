class_name Obstacle
extends Area2D

signal hit 
signal scored 

func _ready()->void:
	add_to_group("pipes")

func move(amount: float)->void:
	position.x -= amount 

func is_offscreen() -> bool:
	return position.x < -200

func _on_body_entered(body: Node2D)-> void:
	hit.emit()
	
func _on_score_area_body_entered(body: Node2D) -> void:
	scored.emit()
	
