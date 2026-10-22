extends Control

const UI = preload("res://presentation/ui/VisualTheme.gd")
const Backdrop = preload("res://presentation/screens/MenuBackdrop.gd")
var screen_mode := "main"

func show_screen(mode: String) -> void:
	screen_mode = mode
	get_tree().paused = false
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	theme = UI.make_theme()
	var backdrop := Control.new()
	backdrop.set_meta("show_ghost", mode == "main")
	backdrop.set_script(Backdrop)
	add_child(backdrop)
	backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var margin := MarginContainer.new()
	add_child(margin)
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	for side in ["left", "right"]:
		margin.add_theme_constant_override("margin_" + side, 72)
	for side in ["top", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, 46)
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 14)
	margin.add_child(column)
	column.add_child(UI.label("FLEEING FRIGHT   /   星光逃亡", 17, UI.MINT))
	var gap := Control.new()
	gap.custom_minimum_size.y = 18
	column.add_child(gap)
	match mode:
		"main":
			column.add_child(UI.label("把星光带走。\n把幽灵留在身后。", 49))
			column.add_child(UI.label("一场关于探索、探测与逃离的小小冒险", 20, UI.MUTED))
			column.add_child(UI.label("W A S D  移动   ·   空格  跳跃   ·   J  探测\nESC  暂停   ·   M  静音   ·   V  切换视角", 19, UI.MUTED))
			var start := UI.button("开始探索    →", func(): Global.navigate("res://scenes/menus/level_menu.tscn"))
			start.custom_minimum_size.x = 330
			start.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
			column.add_child(start)
			start.grab_focus()
			column.add_child(UI.label("提示：泡泡会让幽灵显形，也会唤醒它的追逐。", 16, UI.MUTED))
		"levels":
			column.add_child(UI.label("选择你的下一次冒险", 42))
			column.add_child(UI.label("每关独立开放，收集全部星币即可通关。", 19, UI.MUTED))
			for i in range(Global.LEVELS.size()):
				var data: Dictionary = Global.LEVELS[i]
				var index := i
				var button := UI.button("%s    %s     /     %s" % [data.tag, data.title, data.hint], func(): Global.open_level(index))
				button.add_theme_font_size_override("font_size", 18)
				column.add_child(button)
				if i == 0:
					button.grab_focus()
			column.add_child(UI.button("← 返回首页", func(): Global.navigate("res://scenes/menus/main_menu.tscn")))
		"win", "loss":
			var won := mode == "win"
			column.add_child(UI.label("星光收集完成" if won else "被发现了，再试一次吧", 46))
			column.add_child(UI.label("%s   ·   星币 %d / %d   ·   用时 %s" % [Global.LEVELS[Global.level_index].title, Global.collected, Global.total_coins, Global.time_text()], 22, UI.MUTED))
			column.add_child(UI.label("下一段小径，也许藏着新的惊喜。" if won else "先用 J 探测前方；幽灵显形后记得绕行。", 20, UI.MINT))
			if won and Global.level_index + 1 < Global.LEVELS.size():
				column.add_child(UI.button("探索下一关    →", func(): Global.open_level(Global.level_index + 1)))
			var retry := UI.button("再玩一次" if won else "重新挑战", func(): Global.open_level(Global.level_index))
			column.add_child(retry)
			retry.grab_focus()
			column.add_child(UI.button("选择其他关卡", func(): Global.navigate("res://scenes/menus/level_menu.tscn")))
			column.add_child(UI.button("← 返回首页", func(): Global.navigate("res://scenes/menus/main_menu.tscn")))
	var spacer := Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	column.add_child(spacer)
	column.add_child(UI.label("探索  /  探测  /  收集  /  逃离", 15, UI.MUTED))

func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") and screen_mode != "main":
		Global.navigate("res://scenes/menus/main_menu.tscn")
	elif event is InputEventKey and event.pressed and not event.echo and event.physical_keycode == KEY_M:
		Global.toggle_mute()
