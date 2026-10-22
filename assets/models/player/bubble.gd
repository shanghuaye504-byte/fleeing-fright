extends Area3D

@export var speed: float = 10.0
var direction: Vector3 = Vector3.FORWARD
var start_position: Vector3

var trail_color: Color = Color(1.0, 0.3, 1.0, 0.2)

func _ready():
	set_as_top_level(true)
	start_position = global_position
	$shoot.play()
	
	
func _physics_process(delta):
	position += direction * speed * delta
	
func _on_body_entered(body):
	if body.has_method("on_hit_by_bubble"):
		body.on_hit_by_bubble()
		create_trail_trace(global_position)
		queue_free()
		
	elif not body.is_in_group("player"):
		print("not player!")
		print(body)
		create_trail_trace(global_position)
		queue_free()
		
func create_trail_trace(hit_pos: Vector3):
	var trace_mesh = MeshInstance3D.new()
	var box = BoxMesh.new()
	
	var distance = start_position.distance_to(hit_pos)
	box.size = Vector3(1.0, 0.001, distance)
	trace_mesh.mesh = box
	
	var mat = StandardMaterial3D.new()
	mat.albedo_color = trail_color
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.emission_enabled = true
	mat.emission = trail_color
	mat.emission_energy_multiplier = 1.0
	trace_mesh.material_override = mat
	
	get_tree().root.add_child(trace_mesh)
	print("bubble position:", start_position)
	trace_mesh.global_position = (start_position + hit_pos) / 2.0 - Vector3(0.0, 0.5, 0.0)
	print(" trial positon:", trace_mesh.global_position)
	if start_position.distance_squared_to(hit_pos) > 0.001:
		trace_mesh.look_at(hit_pos - Vector3(0.0, 0.5, 0.0), Vector3.UP)
		
		var tween = trace_mesh.create_tween()
		
		tween.tween_interval(30)
		tween.tween_property(trace_mesh, "transparency", 1.0, 0.5)
		tween.tween_callback(trace_mesh.queue_free)
	
