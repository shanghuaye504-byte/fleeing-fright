extends CharacterBody3D
signal player_caught


@export var MOVE_SPEED = 2

@export var GRID_SIZE= 1.0

var animation


var is_moving: bool = false
var target_position: Vector3
var current_direction: Vector3 = Vector3.FORWARD




var player_node: Node3D = null

func _ready():
	snap_to_grid()
	target_position = global_position
	animation = $shark_modeling/AnimationPlayer
	if animation == null:
		print("播放失败")
	if animation.get_animation_list().size() > 0:
		var first_anim_name = animation.get_animation_list()[0]
		print("第一个动画名称: ", first_anim_name)
		
		var animation_player = animation.get_animation(first_anim_name)
		if animation_player:
			animation_player.loop_mode = Animation.LOOP_LINEAR
			
			# 3. 播放动画
			animation.play(first_anim_name)
	
	
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		player_node = players[0]
		print("成功了！")
		
		
func _physics_process(delta):
	if is_moving:
		process_movement(delta)
	else:
		process_decision()
		


		
func process_movement(delta):
	global_position = global_position.move_toward(target_position, MOVE_SPEED * delta)
	if global_position.distance_to(target_position) < 0.001:
		global_position = target_position
		is_moving = false
		
func process_decision():
	
	if abs(global_position.y - player_node.global_position.y) > 0.5:
		move_randomly()
	else:
		move_chasing_player()
		
		
func move_randomly():
	var valid_directions = get_valid_directions()
	if valid_directions.size() ==0: return
	
	if current_direction in valid_directions and randf() <0.7:
		start_moving(current_direction)
	else:
		var random_dir = valid_directions.pick_random()
		start_moving(random_dir)
		
func move_chasing_player():
	if not is_instance_valid(player_node):
		move_randomly()
		return
		
	var valid_directions = get_valid_directions()
	if valid_directions.size() == 0: return
	var best_direction = Vector3.ZERO
	var shortest_distance = 99999.0
	
	for dir in valid_directions:
		var next_tile_pos = global_position + (dir * GRID_SIZE)
		var dist_to_player = next_tile_pos.distance_to(player_node.global_position)
		
		if dist_to_player < shortest_distance:
			shortest_distance = dist_to_player
			best_direction = dir
			
	if best_direction != Vector3.ZERO:
		start_moving(best_direction)
			
func get_valid_directions() -> Array:
	var dirs = [Vector3.FORWARD, Vector3.BACK, Vector3.LEFT, Vector3.RIGHT]
	var valid = []
	for dir in dirs:
		if can_move_in_direction(dir):
			valid.append(dir)
	#print(valid)
	return valid
	
func start_moving(dir: Vector3):
	current_direction = dir
	target_position = global_position + (dir * GRID_SIZE)
	is_moving = true
	look_at(global_position - dir, Vector3.UP)
	
#func can_move_in_direction(dir: Vector3) -> bool:
	#raycast.target_position = dir * GRID_SIZE
	#raycast.force_raycast_update()
	#return not raycast.is_colliding()
func can_move_in_direction(dir: Vector3) -> bool:
	var space_state = get_world_3d().direct_space_state
	
	var from = global_position
	var to = global_position + (dir * 2 * GRID_SIZE)
	
	var query = PhysicsRayQueryParameters3D.create(from, to)
	
	# detect obstacle
	
	query.collision_mask = (1 << 0) | (1 << 6)  # detect layer 1 and layer 7
	query.exclude = []
	
	var result = space_state.intersect_ray(query)
	
	# 调试信息
	if not result.is_empty():
		print("检测到障碍物: ", result.collider.name, " 层: ", result.collider.collision_layer)
	
	return result.is_empty()
	
func snap_to_grid():
	print(GRID_SIZE)
	var x = round(global_position.x / GRID_SIZE) * GRID_SIZE
	var z = round(global_position.z / GRID_SIZE) * GRID_SIZE
	global_position = Vector3(x, global_position.y, z)
	
func stop_movement():
	
	is_moving = false
	target_position = global_position  
	velocity = Vector3.ZERO
	
	
	set_physics_process(false)


#func _on_area_3d_body_entered(body: Node3D) -> void:
#
	#get_tree().change_scene_to_file("res://scenes/levels/Level_0.tscn")


func _on_area_3d_body_entered(body: Node3D) -> void:
	Global.level1coins = 0
	Global.level2coins = 0
	Global.level3coins = 0
	
	if body.is_in_group("player"):
		player_caught.emit()
	
	
	stop_movement()
	print("movement_stop")
		
	$AudioStreamPlayer.play()
	
	var timer = get_tree().create_timer(2)
	await timer.timeout
	
	
		
	get_tree().change_scene_to_file("res://scenes/menus/game_over_menu.tscn")
