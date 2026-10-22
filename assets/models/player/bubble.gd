extends Area3D

@export var speed: float = 10.0
var direction: Vector3 = Vector3.FORWARD
var start_position: Vector3
var lifetime := 0.0
var hit := false

func _ready() -> void:
	set_as_top_level(true)
	start_position = global_position
	$shoot.volume_db = -17.0
	$shoot.play()

func _physics_process(delta: float) -> void:
	lifetime += delta
	position += direction * speed * delta
	if lifetime >= 2.5:
		queue_free()

func _on_body_entered(body: Node3D) -> void:
	if hit or body.is_in_group("player"):
		return
	hit = true
	if body.has_method("on_hit_by_bubble"):
		body.on_hit_by_bubble()
	create_trail_trace(global_position)
	queue_free()

func create_trail_trace(hit_pos: Vector3) -> void:
	var distance := start_position.distance_to(hit_pos)
	if distance < 0.03:
		return
	var trace := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = Vector3(0.12, 0.012, distance)
	trace.mesh = box
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.42, 0.94, 0.84, 0.4)
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	trace.material_override = mat
	get_tree().current_scene.add_child(trace)
	trace.global_position = (start_position + hit_pos) / 2.0 - Vector3(0.0, 0.45, 0.0)
	trace.look_at(hit_pos - Vector3(0.0, 0.45, 0.0), Vector3.UP)
	var tween := trace.create_tween()
	tween.tween_property(trace, "transparency", 1.0, 0.9)
	tween.tween_callback(trace.queue_free)
