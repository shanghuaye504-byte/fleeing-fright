extends CanvasLayer

const UI = preload("res://presentation/ui/VisualTheme.gd")
var counter: Label
var clock_label: Label
var status: Label
var mute_button: Button
var pause_panel: PanelContainer

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	layer = 10
	var root := Control.new()
	add_child(root)
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.theme = UI.make_theme()
	var top_panel := PanelContainer.new()
	root.add_child(top_panel)
	top_panel.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	top_panel.offset_left = 24
	top_panel.offset_right = -24
	top_panel.offset_top = 18
	top_panel.add_theme_stylebox_override("panel", UI.box(Color(0.04, 0.09, 0.15, 0.92)))
	var top := HBoxContainer.new()
	top_panel.add_child(top)
	top.add_theme_constant_override("separation", 12)
	var title := UI.label(Global.LEVELS[Global.level_index].tag + "  /  " + Global.LEVELS[Global.level_index].title, 21)
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top.add_child(title)
	counter = UI.label("", 23, UI.MINT)
	top.add_child(counter)
	clock_label = UI.label("00:00", 21)
	top.add_child(clock_label)
	var view_button := UI.button("视角 V", toggle_view)
	view_button.focus_mode = Control.FOCUS_NONE
	view_button.add_theme_font_size_override("font_size", 16)
	top.add_child(view_button)
	mute_button = UI.button("静音 M", toggle_mute)
	mute_button.focus_mode = Control.FOCUS_NONE
	mute_button.add_theme_font_size_override("font_size", 16)
	top.add_child(mute_button)
	var pause_button := UI.button("暂停 ESC", toggle_pause)
	pause_button.focus_mode = Control.FOCUS_NONE
	pause_button.add_theme_font_size_override("font_size", 16)
	top.add_child(pause_button)
	var footer := PanelContainer.new()
	root.add_child(footer)
	footer.add_theme_stylebox_override("panel", UI.box(Color(0.04, 0.09, 0.15, 0.9)))
	footer.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	footer.offset_left = 24
	footer.offset_right = -24
	footer.offset_top = -72
	footer.offset_bottom = -18
	status = UI.label("W A S D  移动    空格  跳跃    J  泡泡探测    ·    收集全部星币，避开敌人", 18, UI.MUTED)
	footer.add_child(status)
	pause_panel = PanelContainer.new()
	root.add_child(pause_panel)
	pause_panel.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	pause_panel.offset_left = -210
	pause_panel.offset_right = 210
	pause_panel.offset_top = -190
	pause_panel.offset_bottom = 190
	pause_panel.add_theme_stylebox_override("panel", UI.box(UI.INK, UI.MINT))
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 12)
	pause_panel.add_child(column)
	column.add_child(UI.label("在这里歇一会儿", 28))
	column.add_child(UI.button("继续探索", toggle_pause))
	column.add_child(UI.button("重新开始", func(): Global.open_level(Global.level_index)))
	column.add_child(UI.button("选择关卡", func(): Global.navigate("res://scenes/menus/level_menu.tscn")))
	column.add_child(UI.button("返回首页", func(): Global.navigate("res://scenes/menus/main_menu.tscn")))
	pause_panel.hide()
	Global.coins_changed.connect(update_counter)
	Global.run_finished.connect(show_result)
	update_counter(Global.collected, Global.total_coins)
	update_mute_label()

func _process(_delta: float) -> void:
	clock_label.text = Global.time_text()

func update_counter(count: int, total: int) -> void:
	counter.text = "✦  %02d / %02d   " % [count, total]

func show_result(won: bool) -> void:
	status.text = "全部星币已收集，前往下一段冒险……" if won else "被抓住了！下次记得先探测，再绕行。"
	status.add_theme_color_override("font_color", UI.MINT if won else Color("efa9b9"))

func toggle_pause() -> void:
	if not Global.run_active:
		return
	get_tree().paused = not get_tree().paused
	pause_panel.visible = get_tree().paused
	if pause_panel.visible:
		pause_panel.get_child(0).get_child(1).grab_focus()
	else:
		get_viewport().gui_release_focus()

func toggle_mute() -> void:
	Global.toggle_mute()
	update_mute_label()

func update_mute_label() -> void:
	mute_button.text = "取消静音 M" if Global.muted else "静音 M"

func toggle_view() -> void:
	var camera := get_viewport().get_camera_3d()
	if camera != null and camera.has_method("toggle_view"):
		camera.toggle_view()

func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		toggle_pause()
		get_viewport().set_input_as_handled()
	elif event is InputEventKey and event.pressed and not event.echo and event.physical_keycode == KEY_M:
		toggle_mute()
		get_viewport().set_input_as_handled()
	elif event is InputEventKey and event.pressed and not event.echo and event.physical_keycode == KEY_V:
		toggle_view()
		get_viewport().set_input_as_handled()
