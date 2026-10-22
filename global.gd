extends Node

signal coins_changed(collected: int, total: int)
signal run_finished(won: bool)

const LEVELS = [
	{"path": "res://scenes/levels/Level0.tscn", "title": "初见幽灵", "hint": "收集 8 枚星币，先用 J 探测前方", "tag": "01 · 庭院"},
	{"path": "res://scenes/levels/Level1.tscn", "title": "错层回廊", "hint": "跳上高台，避开横向巡逻的独眼怪", "tag": "02 · 遗迹"},
	{"path": "res://scenes/levels/Level2.tscn", "title": "水岸追逐", "hint": "留意水面下的鲨鱼与隐形幽灵", "tag": "03 · 水岸"},
	{"path": "res://scenes/levels/MoonGarden.tscn", "title": "月光花园", "hint": "沿环形小径探索，探测后及时绕行", "tag": "04 · 奖励关"}
]

var level_index := 0
var collected := 0
var total_coins := 0
var elapsed := 0.0
var run_active := false
var run_serial := 0
var muted := false
var last_won := false

func _process(delta: float) -> void:
	if run_active:
		elapsed += delta

func begin_level(path: String) -> void:
	run_serial += 1
	for i in range(LEVELS.size()):
		if LEVELS[i].path == path:
			level_index = i
	collected = 0
	elapsed = 0.0
	total_coins = get_tree().get_nodes_in_group("coins").size()
	run_active = true
	coins_changed.emit(collected, total_coins)

func collect_coin() -> void:
	if not run_active:
		return
	collected += 1
	coins_changed.emit(collected, total_coins)
	if total_coins > 0 and collected >= total_coins:
		finish_run(true)

func finish_run(won: bool) -> void:
	if not run_active:
		return
	run_active = false
	last_won = won
	var serial := run_serial
	for player in get_tree().get_nodes_in_group("player"):
		player.can_move = false
		player.velocity = Vector3.ZERO
	for enemy in get_tree().get_nodes_in_group("enemy"):
		if enemy is CharacterBody3D:
			enemy.set_physics_process(false)
	run_finished.emit(won)
	await get_tree().create_timer(0.8 if won else 1.8, false).timeout
	if serial != run_serial:
		return
	get_tree().change_scene_to_file("res://scenes/menus/succeed_menu.tscn" if won else "res://scenes/menus/game_over_menu.tscn")

func open_level(index: int) -> void:
	level_index = clampi(index, 0, LEVELS.size() - 1)
	navigate(LEVELS[level_index].path)

func navigate(path: String) -> void:
	run_serial += 1
	run_active = false
	get_tree().paused = false
	get_tree().change_scene_to_file(path)

func toggle_mute() -> void:
	muted = not muted
	AudioServer.set_bus_mute(0, muted)

func time_text() -> String:
	var seconds := int(elapsed)
	return "%02d:%02d" % [seconds / 60, seconds % 60]
