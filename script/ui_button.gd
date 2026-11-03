class_name UIButton
extends Button
## Tombol standar untuk semua UI (modular concept: UI Components).
## Memberi feedback seragam: membesar saat hover, mengecil saat ditekan,
## dan memutar suara "click". Pasang script ini ke Button mana pun.


func _ready() -> void:
	pivot_offset = size / 2.0
	resized.connect(func(): pivot_offset = size / 2.0)

	mouse_entered.connect(func(): Fx.pop(self, 1.08, 0.15))
	button_down.connect(func(): scale = Vector2.ONE * 0.94)
	button_up.connect(func(): scale = Vector2.ONE)
	pressed.connect(func(): AudioManager.play_sfx("click", 0.05))
	
