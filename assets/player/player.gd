extends CharacterBody3D

class_name Player;

@export var jump_velocity: float = 4.5
@export var move_speed: float = 3.0
@export var run_speed: float = 6.0
@export var mouse_sensivity: float = 0.005
@export var gamepad_sensivity: float = 2
@export var max_up_rotation_angle: float = 30
@export var max_down_rotation_angle: float = 70
@export var right_hand: Node3D
@onready var camera := $Camera3D

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _input(event):
	if event is InputEventMouseMotion && Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		rotate_handle(event.relative * mouse_sensivity)
	elif event is InputEventMouseButton && Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func rotate_handle(shift: Vector2):
	rotate_y(-shift.x)
	camera.rotation.x = clampf(camera.rotation.x - shift.y, -deg_to_rad(max_down_rotation_angle), deg_to_rad(max_up_rotation_angle))

func _physics_process(delta: float):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	var camera_axis = Input.get_vector("rotate_left", "rotate_right", "rotate_up", "rotate_down")
	rotate_handle(Vector2(camera_axis.x*abs(camera_axis.x), camera_axis.y*abs(camera_axis.y))*delta*gamepad_sensivity)

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
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
