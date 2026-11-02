class_name MovingPipe
extends Pipe

var t:= 0.0

func move(amount: float)->void:
	super.move(amount)
	t += 0.05
	position.y += sin(t)*2
