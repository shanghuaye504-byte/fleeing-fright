extends Node3D
@export var ghost_scene: PackedScene


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	randomize() 
	spawn_enemies_per_height()

func spawn_enemies_per_height():
	var coin_pos = get_tree().get_nodes_in_group("coins")
	print(coin_pos)
	#classify coins by different heights
	var coins_by_height = {}
	# get the positions of all the coins:
	# and rank them by their heights
	# randomly choose coin positions in different heights to spawn ghost
	
	for coin in coin_pos:
		var h = int(round(coin.global_position.y))
		if not coins_by_height.has(h):
			coins_by_height[h] = []
			print(h)
		coins_by_height[h].append(coin.global_position)
		
	
	var positions: Array = coins_by_height[0]
	print(positions)
	positions.shuffle()
		
	var num = min(2, positions.size())
	for i in range(num):
		var spawn_pos = positions[i]
		var ghost = ghost_scene.instantiate()
		add_child(ghost)
		ghost.global_position = spawn_pos
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
