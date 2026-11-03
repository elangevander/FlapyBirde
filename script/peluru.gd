extends Area2D

var speed = 700.0
@onready var sprite = $Sprite2D

func _ready():
	if sprite:
		var total_frames = sprite.hframes * sprite.vframes
		sprite.frame = randi_range(0, total_frames-1)
	
func _process(delta):
	var main_scene = get_tree().current_scene
	if main_scene and not main_scene.game_running:
		return
		
	position.x -= speed * delta

func _on_body_entered(body):
	if body.name.to_lower() == "bird":
		var main_scene = get_tree().current_scene
		if main_scene and main_scene.has_method("bird_hit"):
			main_scene.bird_hit()
		queue_free()
