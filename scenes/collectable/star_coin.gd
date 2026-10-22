extends Area3D

var collected := false
var base_height := 0.0
var phase := 0.0

func _ready() -> void:
	global_position.x = round(global_position.x)
	global_position.z = round(global_position.z)
	base_height = $StarCoin.position.y
	phase = global_position.x * 0.7 + global_position.z
	$Collected.volume_db = -12.0

func _process(delta: float) -> void:
	rotate_y(2.0 * delta)
	phase += delta * 2.5
	$StarCoin.position.y = base_height + sin(phase) * 0.08

func _on_body_entered(body: Node3D) -> void:
	if collected or not body.is_in_group("player") or not Global.run_active:
		return
	collected = true
	set_deferred("monitoring", false)
	$StarCoin.hide()
	$Collected.play()
	Global.collect_coin()
	await get_tree().create_timer(0.6, false).timeout
	queue_free()
