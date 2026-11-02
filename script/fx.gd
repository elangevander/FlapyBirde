class_name Fx
extends RefCounted
## Kumpulan animasi kecil berbasis Tween (modular concept: Animations).
## Pemakaian: Fx.pop($ScoreLabel), Fx.squash($Sprite), dst. (tanpa instance).
## Tween lama pada node yang sama otomatis dihentikan supaya tidak bertumpuk.

static func _new_tween(node: Node, key: String) -> Tween:
	var meta_key := "fx_" + key
	if node.has_meta(meta_key):
		var old: Tween = node.get_meta(meta_key)
		if old and old.is_valid():
			old.kill()
	var tw := node.create_tween()
	node.set_meta(meta_key, tw)
	return tw


## Label/Control membesar sebentar lalu kembali (cocok untuk skor).
static func pop(node: Control, scale_to: float = 1.3, duration: float = 0.2) -> void:
	node.pivot_offset = node.size / 2.0
	node.scale = Vector2.ONE
	var tw := _new_tween(node, "pop")
	tw.tween_property(node, "scale", Vector2.ONE * scale_to, duration * 0.5) \
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.tween_property(node, "scale", Vector2.ONE, duration * 0.5)


## Berdenyut terus-menerus (cocok untuk teks "klik untuk memulai").
static func pulse(node: Control, amount: float = 1.08, duration: float = 0.6) -> void:
	node.pivot_offset = node.size / 2.0
	node.scale = Vector2.ONE
	var tw := _new_tween(node, "pulse").set_loops()
	tw.tween_property(node, "scale", Vector2.ONE * amount, duration).set_trans(Tween.TRANS_SINE)
	tw.tween_property(node, "scale", Vector2.ONE, duration).set_trans(Tween.TRANS_SINE)


## Efek gepeng-melar singkat (cocok untuk burung saat flap).
static func squash(node: Node2D, duration: float = 0.18) -> void:
	node.scale = Vector2(0.85, 1.2)
	_new_tween(node, "squash").tween_property(node, "scale", Vector2.ONE, duration) \
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


## Berkedip warna lalu kembali normal (cocok untuk efek terkena pipa).
static func flash(node: CanvasItem, color: Color = Color(1, 0.3, 0.3), duration: float = 0.3) -> void:
	node.modulate = color
	_new_tween(node, "flash").tween_property(node, "modulate", Color.WHITE, duration)
