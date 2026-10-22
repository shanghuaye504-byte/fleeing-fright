extends CharacterBody3D
signal player_caught


@export var MOVE_SPEED = 4.0
@export var GRID_SIZE= 1.0
var animation


var is_moving: bool = false
var target_position
var move_direction = Vector3(1.0, 0.0, 0.0)


var player_node: Node3D = null

func _ready():
	snap_to_grid()
	target_position = global_position
	print("one eye monster spawned")
	#print(raycast == null)
	#print(ghost == null)
	#print(body_mesh == null)
	
	animation = $Walk_Slime_Anim/AnimationPlayer
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
	
	while not can_move_in_direction(move_direction):
		move_direction.x = -move_direction.x
		print("inloop")
		
	start_moving(move_direction)
	
		

	
func start_moving(dir: Vector3):
	
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
	var to = global_position + (dir * GRID_SIZE)
	
	var query = PhysicsRayQueryParameters3D.create(from, to)
	
	# detect obstacle
	
	query.collision_mask = (1 << 0)   # detect layer 1 and layer 7
	query.exclude = []
	
	var result = space_state.intersect_ray(query)
	
	## 调试信息
	#if not result.is_empty():
		#print("检测到障碍物: ", result.collider.name, " 层: ", result.collider.collision_layer)
	
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





func _on_player_catcher_body_entered(body: Node3D) -> void:
	Global.level1coins = 0
	Global.level2coins = 0
	Global.level3coins = 0
	
	if body.is_in_group("player"):
		player_caught.emit()
	
	
		stop_movement()
		print("movement_stop")
		
		$AudioStreamPlayer.play()
	# only 2 sceond
		await get_tree().create_timer(3.0).timeout
		$AudioStreamPlayer.stop()
		
		get_tree().change_scene_to_file("res://scenes/menus/game_over_menu.tscn")
