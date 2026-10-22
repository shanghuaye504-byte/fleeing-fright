extends SceneTree

const DIRECTIONS := [Vector2i.RIGHT, Vector2i.LEFT, Vector2i.UP, Vector2i.DOWN]
var game: Node
var player: CharacterBody3D
var blocked := {}
var failed := false

func _initialize() -> void:
	call_deferred("run")

func route(start: Vector2i, target: Vector2i) -> Array:
	var frontier := [start]
	var parents := {start: start}
	while not frontier.is_empty():
		var cell: Vector2i = frontier.pop_front()
		if cell == target:
			var result := [cell]
			while cell != start:
				cell = parents[cell]
				result.push_front(cell)
			return result
		for direction in DIRECTIONS:
			var next: Vector2i = cell + direction
			if absi(next.x) >= 6 or absi(next.y) >= 5 or blocked.has(next) or parents.has(next):
				continue
			parents[next] = cell
			frontier.append(next)
	return []

func fail(message: String) -> void:
	failed = true
	push_error(message)

func run() -> void:
	game = root.get_node("Global")
	game.open_level(3)
	await create_timer(0.3).timeout
	player = get_first_node_in_group("player")
	for enemy in get_nodes_in_group("enemy"):
		if enemy is CharacterBody3D:
			enemy.set_physics_process(false)
			blocked[Vector2i(roundi(enemy.position.x), roundi(enemy.position.z))] = true
	for x in [-2, 2]:
		for z in [-1, 0, 1]:
			blocked[Vector2i(x, z)] = true
	var destinations := []
	for coin in get_nodes_in_group("coins"):
		destinations.append(Vector2i(roundi(coin.position.x), roundi(coin.position.z)))
	for target in destinations:
		var start := Vector2i(roundi(player.position.x), roundi(player.position.z))
		var path := route(start, target)
		if path.is_empty():
			fail("No path to coin " + str(target))
			break
		for i in range(1, path.size()):
			var direction: Vector2i = path[i] - path[i - 1]
			var action := "ui_right" if direction.x > 0 else "ui_left" if direction.x < 0 else "ui_down" if direction.y > 0 else "ui_up"
			Input.action_press(action)
			var ticks := 0
			while game.run_active and ticks < 120:
				await physics_frame
				ticks += 1
				var pos := Vector2(player.position.x, player.position.z)
				if pos.distance_to(Vector2(path[i])) < 0.09:
					break
			Input.action_release(action)
			if ticks >= 120:
				fail("Movement blocked at " + str(path[i]))
				break
		if failed or not game.run_active:
			break
	if game.collected != 10 or not game.last_won:
		fail("Expected victory with all 10 coins, collected " + str(game.collected))
	await create_timer(1.0).timeout
	if not current_scene.scene_file_path.ends_with("succeed_menu.tscn"):
		fail("Expected victory scene after walking route")
	game.navigate("res://scenes/menus/main_menu.tscn")
	await create_timer(0.1).timeout
	current_scene.queue_free()
	await process_frame
	await process_frame
	print("GARDEN WALK: " + ("FAIL" if failed else "PASS — all 10 coins collected through actual movement, no teleport"))
	quit(1 if failed else 0)
