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
@onready var scale_audio: AudioStreamPlayer = $ScaleAudio
@onready var drag_ray: RayCast3D = %DragRay
@onready var hand: Marker3D = %Hand
@onready var action_label: Label = %ActionLabel
var item: Draggable

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
	elif event.is_action_pressed("interact"):
		interact()

func  _process(delta: float) -> void:
	scale_animation(delta)
	check_interaction()

func _physics_process(delta: float):
	if item:
		item.global_transform = hand.global_transform
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
		scale_audio.play()
		scale_audio.pitch_scale = randf_range(0.9, 1.5)
	elif state == ScaleState.MIN || state == ScaleState.MINIMIZING:
		if big_scale_cast.is_colliding():
			#TODO: destroy chests
			return
		state = ScaleState.MAXIMIZING
		scale_audio.play()
		scale_audio.pitch_scale = randf_range(0.9, 1.5)


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

func check_interaction():
	if drag_ray.is_colliding():
		var collider = drag_ray.get_collider()
		if collider is Triggable:
			if item && collider.activable(item.trigger):
				action_label.text = "[E] to %s" % collider.action_name
			elif !collider.activated:
				action_label.text = "%s is needed" % collider.trigger.name
		elif collider is Draggable:
			action_label.text = "[E] - Drag %s" % collider.trigger.name
	elif action_label.text != "":
		action_label.text = ""

func interact():
	var collider = drag_ray.get_collider()
	if item && collider is Triggable && collider.activate(item.trigger):
		item.queue_free()
		item = null
		action_label.text = ""
		return
	if collider is Draggable:
		if item:
			item.global_transform = collider.global_transform
			item.drop()
		item = collider
		item.drag()
