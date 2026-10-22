extends RefCounted

const INK := Color("101d30")
const PANEL := Color("14273e")
const MINT := Color("80e4cb")
const TEXT := Color("edf5ef")
const MUTED := Color("9db4c3")

static func box(color: Color, border := Color.TRANSPARENT, radius := 14) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.border_color = border
	style.set_border_width_all(1)
	style.set_corner_radius_all(radius)
	style.content_margin_left = 22
	style.content_margin_right = 22
	style.content_margin_top = 14
	style.content_margin_bottom = 14
	return style

static func make_theme() -> Theme:
	var theme := Theme.new()
	var font := SystemFont.new()
	font.font_names = PackedStringArray(["PingFang SC", "Microsoft YaHei", "Noto Sans CJK SC", "sans-serif"])
	theme.default_font = font
	theme.default_font_size = 20
	theme.set_color("font_color", "Label", TEXT)
	theme.set_color("font_color", "Button", TEXT)
	theme.set_color("font_hover_color", "Button", INK)
	theme.set_color("font_focus_color", "Button", TEXT)
	theme.set_stylebox("normal", "Button", box(PANEL, Color("315068")))
	theme.set_stylebox("hover", "Button", box(MINT, MINT))
	theme.set_stylebox("pressed", "Button", box(Color("439d91")))
	theme.set_stylebox("focus", "Button", box(Color(0, 0, 0, 0), MINT))
	return theme

static func label(text: String, size: int, color := TEXT) -> Label:
	var node := Label.new()
	node.text = text
	node.add_theme_font_size_override("font_size", size)
	node.add_theme_color_override("font_color", color)
	return node

static func button(text: String, action: Callable) -> Button:
	var node := Button.new()
	node.text = text
	node.custom_minimum_size.y = 52
	node.pressed.connect(action)
	return node
