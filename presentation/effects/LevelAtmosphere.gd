extends Node3D

const HUD = preload("res://presentation/ui/GameHUD.gd")
const CAMERA = preload("res://presentation/effects/FollowCamera.gd")

func _ready() -> void:
	call_deferred("start_level")

func start_level() -> void:
	Global.begin_level(get_tree().current_scene.scene_file_path)
	var camera := get_viewport().get_camera_3d()
	if camera == null:
		camera = get_tree().current_scene.get_node_or_null("Camera3D")
	if camera != null:
		camera.set_script(CAMERA)
		camera.setup(get_tree().get_first_node_in_group("player"), get_tree().get_nodes_in_group("coins"), Global.level_index)
	var hud := CanvasLayer.new()
	hud.set_script(HUD)
	add_child(hud)
	var material := StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = Color("a0e2d3")
	var sphere := SphereMesh.new()
	sphere.radius = 0.035
	sphere.height = 0.07
	for i in range(32):
		var star := MeshInstance3D.new()
		star.mesh = sphere
		star.material_override = material
		star.position = Vector3(sin(i * 5.7) * 22.0, 3.0 + fmod(i * 1.7, 8.0), -13.0 - fmod(i * 3.1, 14.0))
		add_child(star)

	var ambience := AudioStreamPlayer.new()
	var stream := load("res://assets/audio/sfx/kenney_sci-fi-sounds/Audio/spaceEngineLow_000.ogg").duplicate() as AudioStreamOggVorbis
	stream.loop = true
	ambience.stream = stream
	ambience.volume_db = -32.0
	add_child(ambience)
	ambience.play()
