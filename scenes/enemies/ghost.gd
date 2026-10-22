extends CharacterBody3D
signal player_caught


@export var MOVE_SPEED = 0.5
@export var GRID_SIZE= 1.0
var animation



var is_moving: bool = false
var target_position: Vector3
var current_direction: Vector3 = Vector3.FORWARD
var is_hidden: bool = true


@onready var ghost = $Ghost_animation
@onready var body_mesh = ghost.find_child("Ghost")
@onready var audio_players = [
	$AudioStreamPlayer,
	$AudioStreamPlayer2,
	$AudioStreamPlayer3,
	$AudioStreamPlayer4
]

var player_node: Node3D = null

func _ready():
	snap_to_grid()
	target_position = global_position
	#print(raycast == null)
	#print(ghost == null)
	#print(body_mesh == null)
	
	body_mesh.transparency = 1.0
	ghost.hide()
	is_hidden = true
	
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		player_node = players[0]
		
		
func _physics_process(delta):
	if is_moving:
		process_movement(delta)
	else:
		process_decision()
		
func on_hit_by_bubble():
	if is_hidden:
		
		self_reveal()
		#sfx or visual effect
	else:
		pass
		
func self_reveal():
	if not is_hidden:
		return
	is_hidden = false
	ghost.show()
	
	var tween = create_tween()
	
	tween.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(body_mesh, "transparency", 0.0, 0.45)
	$AudioStreamPlayer5.play()
	animation = $Ghost_animation/AnimationPlayer
	if animation == null:
		return
	if animation.get_animation_list().size() > 0:
		var first_anim_name = animation.get_animation_list()[0]
		
			
			# player
		animation.play(first_anim_name)
		
		
		
func process_movement(delta):
	global_position = global_position.move_toward(target_position, MOVE_SPEED * delta)
	if global_position.distance_to(target_position) < 0.001:
		global_position = target_position
		is_moving = false
		
func process_decision():
	if not is_instance_valid(player_node):
		return
	if is_hidden:
		pass
	elif abs(global_position.y - player_node.global_position.y) > 0.5:
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
	var to = global_position + (dir * GRID_SIZE)
	
	var query = PhysicsRayQueryParameters3D.create(from, to)
	
	# detect obstacle
	
	query.collision_mask = (1 << 0) | (1 << 6)  # detect layer 1 and layer 7
	query.exclude = []
	
	var result = space_state.intersect_ray(query)
	
	# 调试信息
	return result.is_empty()
	
func snap_to_grid():
	var x = round(global_position.x / GRID_SIZE) * GRID_SIZE
	var z = round(global_position.z / GRID_SIZE) * GRID_SIZE
	global_position = Vector3(x, global_position.y, z)
	
func stop_movement():
	
	is_moving = false
	target_position = global_position  
	velocity = Vector3.ZERO
	
	
	set_physics_process(false)


func _on_area_3d_body_entered(body: Node3D) -> void:
	if not body.is_in_group("player") or not Global.run_active:
		return
	player_caught.emit()
	stop_movement()
	$AudioStreamPlayer.play()
	Global.finish_run(false)
