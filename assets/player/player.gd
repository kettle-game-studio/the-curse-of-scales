extends CharacterBody3D

class_name Player;

@export var settings: Settings
@export_category("Scaling")
@export var min_scale: float = 0.1
@export var scaling_time: float = 0.2
@export_category("Move")
@export var jump_velocity: float = 4.5
@export var move_speed: float = 3.0
@export var run_speed: float = 6.0
@export var max_up_rotation_angle: float = 30
@export var max_down_rotation_angle: float = 70

@onready var camera := %Camera3D
@onready var scale_root: Node3D = $ScaleRoot
@onready var collider: CollisionShape3D = $Collider
@onready var big_scale_cast: ShapeCast3D = $BigScaleCast
@onready var jump_audio: AudioStreamPlayer = $JumpAudio

enum ScaleState { MAX, MIN, MAXIMIZING, MINIMIZING }
var state := ScaleState.MAX
var shape: CapsuleShape3D
var max_shape: CapsuleShape3D
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready() -> void:
	shape = collider.shape as CapsuleShape3D
	max_shape = shape.duplicate()
	big_scale_cast.shape = max_shape

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion && Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		rotate_handle(event.relative * settings.mouse_sensitivity)
	elif event is InputEventMouseButton && Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	elif event.is_action_pressed("change_scale"):
		change_scale()

func  _process(delta: float) -> void:
	scale_animation(delta)

func _physics_process(delta: float):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta
	elif Input.is_action_just_pressed("jump"):
		jump_audio.play()
		velocity.y = jump_velocity

	var camera_axis = Input.get_vector("rotate_left", "rotate_right", "rotate_up", "rotate_down")
	rotate_handle(Vector2(camera_axis.x*abs(camera_axis.x), camera_axis.y*abs(camera_axis.y))*delta*settings.joystick_sensitivity)

	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var input_speed : float = min(input_dir.length(), 1.0)
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y).normalized())
	var speed : float = input_speed * (run_speed if Input.is_action_pressed("run") else move_speed)
	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, move_speed)
		velocity.z = move_toward(velocity.z, 0, move_speed)

	move_and_slide()

func rotate_handle(shift: Vector2):
	rotate_y(-shift.x)
	camera.rotation.x = clampf(camera.rotation.x - shift.y, -deg_to_rad(max_down_rotation_angle), deg_to_rad(max_up_rotation_angle))

func change_scale():
	if state == ScaleState.MAX || state == ScaleState.MAXIMIZING:
		state = ScaleState.MINIMIZING
	elif state == ScaleState.MIN || state == ScaleState.MINIMIZING:
		if big_scale_cast.is_colliding():
			#TODO: destroy chests
			return
		state = ScaleState.MAXIMIZING

var scaling = 1
func scale_animation(delta: float):
	if state == ScaleState.MAX || state == ScaleState.MIN:
		return
	if state == ScaleState.MINIMIZING:
		scaling -= delta/scaling_time
		if scaling <= 0:
			scaling = 0
			state = ScaleState.MIN
	else:
		scaling += delta/scaling_time
		if scaling >= 1:
			scaling = 1
			state = ScaleState.MAX
	var s = lerpf(min_scale, 1, scaling)
	scale_root.scale = Vector3(s, s, s)
	shape.height = max_shape.height*s
	shape.radius = max_shape.radius*s
	collider.position.y = shape.height/2
