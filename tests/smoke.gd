extends SceneTree

var failures := 0
var checks := 0
var game: Node

func _initialize() -> void:
	call_deferred("run")

func check(condition: bool, message: String) -> void:
	checks += 1
	if not condition:
		failures += 1
		push_error("FAIL: " + message)
	else:
		print("PASS: " + message)

func settle(seconds := 0.15) -> void:
	await create_timer(seconds).timeout

func freeze_enemies() -> void:
	for enemy in get_nodes_in_group("enemy"):
		if enemy is CharacterBody3D:
			enemy.set_physics_process(false)

func run() -> void:
	game = root.get_node("Global")
	var expected := [8, 14, 14, 10]
	for index in range(game.LEVELS.size()):
		game.open_level(index)
		await settle()
		freeze_enemies()
		check(current_scene.scene_file_path == game.LEVELS[index].path, "level %d loads" % index)
		check(game.total_coins == expected[index], "level %d has expected coin count" % index)
		check(game.collected == 0 and game.run_active, "level %d starts clean" % index)
		var player: CharacterBody3D = get_first_node_in_group("player")
		await settle(0.4)
		check(player.global_position.y > -1.0 and player.is_on_floor(), "level %d supports player on floor" % index)
		var camera = root.get_camera_3d()
		check(camera != null and camera.has_method("toggle_view"), "level %d has follow camera" % index)
		var hidden_correctly := true
		for enemy in get_nodes_in_group("enemy"):
			if enemy.has_method("on_hit_by_bubble"):
				hidden_correctly = hidden_correctly and enemy.is_hidden and not enemy.ghost.visible
		check(hidden_correctly, "undetected ghosts have no visible model or shadow")
		camera.toggle_view()
		await settle(0.9)
		check(camera.overview and camera.size > camera.follow_size, "overview zooms out")
		var all_coins_visible := true
		var viewport_size: Vector2 = root.get_visible_rect().size
		for item in get_nodes_in_group("coins"):
			var screen: Vector2 = camera.unproject_position(item.global_position)
			all_coins_visible = all_coins_visible and screen.x >= 0 and screen.x <= viewport_size.x and screen.y >= 80 and screen.y <= viewport_size.y - 80
		check(all_coins_visible, "overview keeps all coins inside unobstructed viewport")
		camera.toggle_view()
		await settle(0.2)
		var coins := get_nodes_in_group("coins")
		var coin: Area3D = coins[0]
		var best_clearance := -1.0
		for candidate in coins:
			var clearance := INF
			for enemy in get_nodes_in_group("enemy"):
				if enemy is CharacterBody3D:
					clearance = minf(clearance, candidate.global_position.distance_to(enemy.global_position))
			if clearance > best_clearance:
				best_clearance = clearance
				coin = candidate
		var other := Node3D.new()
		current_scene.add_child(other)
		coin._on_body_entered(other)
		check(game.collected == 0, "non-player cannot collect")
		# Test an actual physics overlap, then replay the signal to check idempotency.
		player.global_position = coin.global_position
		player.velocity = Vector3.ZERO
		await settle(0.05)
		check(game.collected == 1, "physics overlap collects one coin")
		coin._on_body_entered(player)
		check(game.collected == 1, "repeated callback cannot double-count")
		var hud: CanvasLayer = current_scene.get_node("Atmosphere").get_child(0)
		if index == 0:
			hud.toggle_pause()
			var camera_position: Vector3 = camera.global_position
			var elapsed_before: float = game.elapsed
			await settle(0.15)
			check(paused and is_equal_approx(game.elapsed, elapsed_before), "pause stops gameplay timer")
			check(camera.global_position.is_equal_approx(camera_position), "pause also freezes camera")
			hud.toggle_pause()
			check(not paused, "pause menu resumes")
			hud.toggle_mute()
			check(AudioServer.is_bus_mute(0), "mute reaches audio bus")
			hud.toggle_mute()
			check(not AudioServer.is_bus_mute(0), "unmute restores audio bus")
		for item in coins:
			if is_instance_valid(item):
				item._on_body_entered(player)
		check(game.collected == expected[index] and not game.run_active and game.last_won, "level %d completes exactly once" % index)
		await settle(0.9)
		check(current_scene.scene_file_path.ends_with("succeed_menu.tscn"), "victory routes to result screen")
		game.open_level(index)
		await settle()
		check(game.collected == 0 and game.run_active, "restart resets counters")
		freeze_enemies()
		player = get_first_node_in_group("player")
		# Place the actual actor inside a catcher to validate collision-based defeat.
		var actor: CharacterBody3D
		for enemy in get_nodes_in_group("enemy"):
			if enemy is CharacterBody3D:
				actor = enemy
				break
		player.global_position = actor.global_position
		player.velocity = Vector3.ZERO
		await settle(0.05)
		check(not game.run_active and not game.last_won, "enemy collision triggers defeat")
		if actor.has_method("on_hit_by_bubble"):
			check(actor.is_hidden and not actor.ghost.visible, "unprobed ghost stays invisible after catching player")
		get_nodes_in_group("coins")[0]._on_body_entered(player)
		check(game.collected == 0, "defeat blocks late collection")
		await settle(1.9)
		check(current_scene.scene_file_path.ends_with("game_over_menu.tscn"), "defeat routes to result screen")
	game.open_level(3)
	await settle()
	freeze_enemies()
	var ghost: Node3D = current_scene.get_node("GhostWest")
	check(ghost.is_hidden and not ghost.ghost.visible and is_equal_approx(ghost.body_mesh.transparency, 1.0), "ghost starts completely invisible")
	var bubble = load("res://assets/models/player/bubble.tscn").instantiate()
	bubble.position = ghost.global_position + Vector3(0, 0, 1)
	bubble.direction = Vector3.FORWARD
	current_scene.add_child(bubble)
	await settle(0.2)
	check(not ghost.is_hidden and ghost.ghost.visible, "moving bubble reveals ghost through physics collision")
	await settle(0.5)
	check(is_zero_approx(ghost.body_mesh.transparency), "probed ghost becomes fully visible")
	var camera = root.get_camera_3d()
	var focus_before: Vector3 = camera.focus
	Input.action_press("ui_right")
	await settle(0.9)
	Input.action_release("ui_right")
	check(camera.focus.distance_to(focus_before) > 0.2, "camera follows actual movement smoothly")
	var target: CharacterBody3D = get_first_node_in_group("player")
	var screen: Vector2 = camera.unproject_position(target.global_position)
	check(screen.x > 80 and screen.x < 1200 and screen.y > 100 and screen.y < 620, "followed player remains inside usable viewport")
	var focus_height: float = camera.focus.y
	Input.action_press("ui_accept")
	await settle(0.15)
	Input.action_release("ui_accept")
	check(is_equal_approx(camera.focus.y, focus_height), "jump does not bob the camera")
	var flying = load("res://assets/models/player/bubble.tscn").instantiate()
	flying.position = Vector3(0, 10, 0)
	current_scene.add_child(flying)
	await settle(2.7)
	check(not is_instance_valid(flying), "unobstructed bubble expires")
	var traces := 0
	for child in current_scene.get_children():
		if child is MeshInstance3D:
			traces += 1
	check(traces == 0, "probe trails expire within the scene")
	# Test actual blocked raycasts, so a surrounded patrol cannot hang the physics tick.
	var slime = load("res://scenes/enemies/one_eye_monster.tscn").instantiate()
	slime.position = Vector3(30, 1, 30)
	current_scene.add_child(slime)
	slime.set_physics_process(false)
	for offset in [-1, 1]:
		var wall := StaticBody3D.new()
		wall.position = Vector3(30 + offset, 1, 30)
		var shape := CollisionShape3D.new()
		shape.shape = BoxShape3D.new()
		wall.add_child(shape)
		current_scene.add_child(wall)
	await physics_frame
	await physics_frame
	slime.process_decision()
	check(not slime.is_moving, "patrol waits when blocked on both sides")
	game.finish_run(true)
	game.navigate("res://scenes/menus/main_menu.tscn")
	await settle(1.0)
	check(current_scene.scene_file_path.ends_with("main_menu.tscn"), "abandoned result timer cannot hijack navigation")
	game.navigate("res://scenes/menus/level_menu.tscn")
	await settle()
	var buttons := current_scene.find_children("*", "Button", true, false)
	check(buttons.size() == 5, "all four levels and back button are available")
	game.open_level(3)
	await settle()
	var hud: CanvasLayer = current_scene.get_node("Atmosphere").get_child(0)
	hud.toggle_pause()
	game.open_level(3)
	await settle()
	check(not paused and game.run_active and game.collected == 0, "restarting while paused restores gameplay")
	game.navigate("res://scenes/menus/main_menu.tscn")
	await settle()
	current_scene.queue_free()
	await process_frame
	await process_frame
	print("RESULT: %d checks, %d failures" % [checks, failures])
	quit(1 if failures else 0)
