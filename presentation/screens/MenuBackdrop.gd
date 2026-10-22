extends Control

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	resized.connect(queue_redraw)

func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), Color("0b1628"))
	for i in range(64):
		var p := Vector2(fmod(i * 173.9 + 61.0, size.x), fmod(i * 97.3 + 31.0, size.y))
		draw_circle(p, 1.0 if i % 3 else 2.0, Color(0.5, 0.85, 0.8, 0.2 + (i % 4) * 0.08))
	if not get_meta("show_ghost", true):
		return
	var c := Vector2(size.x * 0.78, size.y * 0.43)
	for i in range(4, 0, -1):
		draw_circle(c, 85.0 + i * 22, Color(0.3, 0.75, 0.75, 0.018))
	draw_circle(c, 78, Color("bce9e2"))
	draw_rect(Rect2(c + Vector2(-78, 0), Vector2(156, 69)), Color("bce9e2"))
	for i in range(4):
		draw_circle(c + Vector2(-58.5 + i * 39, 69), 19.5, Color("bce9e2"))
	draw_circle(c + Vector2(-25, 0), 9, Color("14273e"))
	draw_circle(c + Vector2(25, 0), 9, Color("14273e"))
	draw_circle(c + Vector2(-43, 21), 11, Color("e7a7b9"))
	draw_circle(c + Vector2(43, 21), 11, Color("e7a7b9"))
	draw_arc(c + Vector2(0, 16), 12, 0.2, PI - 0.2, 20, Color("14273e"), 3, true)
