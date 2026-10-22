extends Area3D
const ROT_SPEED = 2 # the num of degrees the coin rotate every frame
var GRID_SIZE = 1



var current_scene_name





# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	snap_to_grid()
	current_scene_name = get_tree().current_scene.scene_file_path.get_file().get_basename()
	print(current_scene_name)
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	rotate_y(deg_to_rad(ROT_SPEED))


func _on_body_entered(body: Node3D) -> void:
	if current_scene_name == "Level0":
		print("in first level")
		Global.level1coins += 1
		print(Global.level1coins, "collected")
		$Collected.play()
		await get_tree().create_timer(0.6).timeout
		print($Suceed)
		if Global.level1coins >= Global.max_coins_to_win1:
			Global.level1coins = 0
			get_tree().change_scene_to_file("res://scenes/menus/succeed_menu.tscn")
	
	if current_scene_name == "Level1":
		print("in second level")
		Global.level2coins += 1
		print(Global.level2coins, "collected")
		$Collected.play()
		await get_tree().create_timer(0.6).timeout
		if Global.level2coins >= Global.max_coins_to_win2:
			Global.level2coins = 0
			get_tree().change_scene_to_file("res://scenes/menus/succeed_menu.tscn")
	
	if current_scene_name == "Level2":
		print("in third level")
		Global.level3coins += 1
		print(Global.level3coins, "collected")
		$Collected.play()
		await get_tree().create_timer(0.6).timeout
		if Global.level3coins >= Global.max_coins_to_win3:
			Global.level3coins = 0
			get_tree().change_scene_to_file("res://scenes/menus/succeed_menu.tscn")
			
	queue_free()
	
	
func snap_to_grid():
	
	var x = round(global_position.x / GRID_SIZE) * GRID_SIZE
	var z = round(global_position.z / GRID_SIZE) * GRID_SIZE
	global_position = Vector3(x, global_position.y, z)
