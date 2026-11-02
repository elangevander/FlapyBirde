class_name MovingPipe
extends Pipe

var t:= 0.0
var base_y := 0.0

func _ready() -> void:
	super._ready()
	base_y = position.y

func move(amount: float) -> void:
	super.move(amount)
	t += 0.05
	position.y = base_y + sin(t) * 60
