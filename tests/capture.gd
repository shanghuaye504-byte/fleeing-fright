extends SceneTree

func _initialize() -> void:
	call_deferred("capture")

func capture() -> void:
	var scenes := [
		["res://scenes/menus/main_menu.tscn", "main-menu"],
		["res://scenes/menus/level_menu.tscn", "level-select"],
		["res://scenes/levels/Level0.tscn", "courtyard"],
		["res://scenes/levels/Level1.tscn", "ruins"],
		["res://scenes/levels/Level2.tscn", "waterfront"],
		["res://scenes/levels/MoonGarden.tscn", "moon-garden"]
	]
	for item in scenes:
		change_scene_to_file(item[0])
		await create_timer(0.5).timeout
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("res://docs/images/" + item[1] + ".png")
		if item[1] == "moon-garden":
			root.get_camera_3d().toggle_view()
			await create_timer(1.0).timeout
			await RenderingServer.frame_post_draw
			root.get_texture().get_image().save_png("res://docs/images/moon-garden-overview.png")
	change_scene_to_file("res://scenes/menus/main_menu.tscn")
	await create_timer(0.2).timeout
	current_scene.queue_free()
	await process_frame
	await create_timer(0.1).timeout
	quit()
