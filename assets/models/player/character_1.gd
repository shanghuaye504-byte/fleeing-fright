extends CharacterBody3D

@export var bubble_scene_path = "res://assets/models/player/bubble.tscn"

# configurations

@export_range(0.0, 30.0, 0.1)
var MOVE_SPEED: float = 3.0

@export_range(0.0, 100.0, 0.1)
var SNAP_SPEED: float = 20.0

@export_range(0.1, 10.0, 0.1)
var GRID_SIZE: float = 1.0
const JUMP_VELOCITY = 4.5
var can_move: bool = true

func _ready():
	await get_tree().create_timer(0.1).timeout
	var enemies = get_tree().get_nodes_in_group("enemy")
	
	for enemy in enemies:
		if enemy.has_signal("player_caught"):
			enemy.player_caught.connect(_on_player_caught)
			print(" connect to enemy")

func _on_player_caught():
	print("Player caught!!")
	can_move = false
	velocity = Vector3.ZERO





func _physics_process(delta: float) -> void:
	if not can_move:
		return
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input action, only allow four direction, diagonal movement is not allowed.
	var input_dir = Vector3.ZERO # the direction
	if Input.is_action_pressed("ui_right"):
		input_dir.x = 1
	elif Input.is_action_pressed("ui_left"):
		input_dir.x = -1
	elif Input.is_action_pressed("ui_up"):
		input_dir.z = -1
	elif Input.is_action_pressed("ui_down"):
		input_dir.z = 1
		
	# If turning made by player, snap player to the centre line of the grid
	if input_dir.x != 0:
		velocity.x = input_dir.x * MOVE_SPEED
		var target_z = round(global_position.z / GRID_SIZE) * GRID_SIZE
		velocity.z = (target_z - global_position.z) * SNAP_SPEED
		if input_dir.x > 0:
			rotation.y = PI * 0.5
		else:
			rotation.y = PI * 1.5
		#var target_direction = Vector3(velocity.x, 0, 0)
		#look_at(target_direction, Vector3.UP)
	
	elif input_dir.z != 0:
		velocity.z = input_dir.z * MOVE_SPEED
		var target_x = round(global_position.x / GRID_SIZE) * GRID_SIZE
		velocity.x = (target_x - global_position.x) * SNAP_SPEED
		if input_dir.z > 0:
			rotation.y = 0
		else:
			rotation.y = PI 
		#var target_direction = Vector3(0, 0, velocity.z)
		#look_at(target_direction, Vector3.UP)
	
	else:
		# if no input, apply inertia.
		velocity.x = move_toward(velocity.x, 0, MOVE_SPEED / 3)
		velocity.z = move_toward(velocity.z, 0, MOVE_SPEED / 3)
		
	move_and_slide()	
	
func shoot_bubble():
	if bubble_scene_path == null:
		print("Error: bubble scene isn't set!")
		return
		
	var bubble_scene := load(bubble_scene_path)
	
	var new_bubble = bubble_scene.instantiate()
	
	
	var target_z = round(global_position.z / GRID_SIZE) * GRID_SIZE
	var target_x = round(global_position.x / GRID_SIZE) * GRID_SIZE
	var traget_y = round(global_position.y / GRID_SIZE) * GRID_SIZE 
	
	
	var spawn_pos = Vector3(target_x, traget_y, target_z)

		
	new_bubble.global_position = spawn_pos
	
	var shoot_dir = global_transform.basis.z
	new_bubble.direction = shoot_dir.normalized()
	
	get_tree().current_scene.add_child(new_bubble)
	
func _process(delta):
	if Input.is_action_just_pressed("shoot"):
		shoot_bubble()
	
	
