extends Node3D

@export var levels: Array[Node3D]
@export var current_level := 0
@export var animation_start_position: Node3D
@export var animation_time: float = 5.0
@export var animation_material: Material

func _ready() -> void:
	for i in range(levels.size()):
		var lvl = levels[i]
		if i <= current_level:
			lvl.visible = true
			lvl.process_mode = Node.PROCESS_MODE_INHERIT
		else:
			lvl.visible = false
			lvl.process_mode = Node.PROCESS_MODE_DISABLED

func recive_bottle(trigger: TriggerItem) -> void:
	if trigger is not Bottle:
		return
	current_level+=1
	var lvl = levels[current_level]
	lvl.visible = true
	progress = 0
	override_material(lvl, animation_material)

func override_material(lvl: Node3D, material: Material):
	for m in lvl.find_children("*", "MeshInstance3D"):
		var mesh = m as MeshInstance3D
		mesh.material_override = material

var progress: float = 1
func new_level_animation(delta: float):
	if progress >= 1:
		return
	progress+=delta/animation_time
	progress = min(1, progress)
	(animation_material as ShaderMaterial).set_shader_parameter("progress", progress)
	var lvl = levels[current_level]
	lvl.position = lerp(animation_start_position.position, Vector3(0, 0, 0), progress)
	lvl.rotation.y = lerp(0.0, 4*TAU, ease(progress, 0.2))
	var scale = lerp(0.25, 1.0, ease(progress, 3.0))
	lvl.scale = Vector3(scale, 1.0, scale)
	if progress >= 1:
		levels[current_level].process_mode = Node.PROCESS_MODE_INHERIT
		override_material(lvl, null)

func _process(delta: float) -> void:
	new_level_animation(delta)
