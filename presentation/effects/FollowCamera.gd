extends Camera3D

var player: Node3D
var focus := Vector3.ZERO
var overview_focus := Vector3.ZERO
var overview_size := 16.0
var follow_size := 10.5
var overview := false
var offset := Vector3(0.65, 1.8, 1.4).normalized() * 28.0

func setup(target: Node3D, coins: Array, level_index: int) -> void:
	player = target
	set_process(true)
	projection = Camera3D.PROJECTION_ORTHOGONAL
	keep_aspect = Camera3D.KEEP_HEIGHT
	current = true
	follow_size = 11.5 if level_index == 1 or level_index == 2 else 10.5
	var minimum := player.global_position
	var maximum := minimum
	for coin in coins:
		minimum = minimum.min(coin.global_position)
		maximum = maximum.max(coin.global_position)
	overview_focus = (minimum + maximum) * 0.5
	overview_focus.y = 1.0
	focus = Vector3(player.global_position.x, 1.0, player.global_position.z)
	global_position = overview_focus + offset
	look_at(overview_focus)
	var min_screen := Vector2(INF, INF)
	var max_screen := Vector2(-INF, -INF)
	for x in [minimum.x - 2.0, maximum.x + 2.0]:
		for z in [minimum.z - 2.0, maximum.z + 2.0]:
			for y in [0.0, maximum.y + 0.8]:
				var point := Vector3(x, y, z) - overview_focus
				var projected := Vector2(global_basis.x.dot(point), global_basis.y.dot(point))
				min_screen = min_screen.min(projected)
				max_screen = max_screen.max(projected)
	var viewport_size := get_viewport().get_visible_rect().size
	var aspect := viewport_size.x / maxf(viewport_size.y, 1.0)
	var span := max_screen - min_screen
	overview_size = maxf(span.y, span.x / aspect) * 1.25
	size = follow_size
	update_pose()

func _process(delta: float) -> void:
	if not is_instance_valid(player):
		return
	var desired := overview_focus
	if not overview:
		desired = focus
		var displacement := Vector3(player.global_position.x - focus.x, 0.0, player.global_position.z - focus.z)
		if displacement.length() > 1.1:
			desired += displacement.normalized() * (displacement.length() - 1.1)
	var blend := 1.0 - exp(-5.0 * delta)
	focus = focus.lerp(desired, blend)
	size = lerpf(size, overview_size if overview else follow_size, blend)
	update_pose()

func update_pose() -> void:
	global_position = focus + offset
	look_at(focus)

func toggle_view() -> void:
	overview = not overview
