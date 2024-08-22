extends Node3D

@export var vertical_min_angle: float = -80.0 # Minimum pitch angle
@export var vertical_max_angle: float = 80.0 # Maximum pitch angle
@export var interpolation_duration: float = 0.5 # Time to complete the interpolation

var shift_modifier: float = 1.0

var target_rotation: Vector3
var interpolation_time: float = 0.0
var is_interpolating: bool = false


func _ready():
	# Initialize the target rotation with the current rotation
	target_rotation = rotation_degrees

func _physics_process(delta):
	shift_modifier = 1.0
	
	if Input.is_action_pressed("shift"):
		shift_modifier = 0.5
	
	if Input.is_action_just_pressed("ui_left"):
		target_rotation.y += 90 * shift_modifier
		start_interpolation()

	if Input.is_action_just_pressed("ui_right"):
		target_rotation.y -= 90 * shift_modifier
		start_interpolation()

	if Input.is_action_just_pressed("ui_up"):
		target_rotation.x += 30 * shift_modifier
		start_interpolation()

	if Input.is_action_just_pressed("ui_down"):
		target_rotation.x -= 30 * shift_modifier
		start_interpolation()

	# Clamp the vertical rotation angle
	target_rotation.x = clamp(target_rotation.x, vertical_min_angle, vertical_max_angle)

	if is_interpolating:
		interpolate_camera(delta)

func start_interpolation():
	# Reset the interpolation time
	interpolation_time = 0.0
	is_interpolating = true

func interpolate_camera(delta):
	# Increment interpolation time
	interpolation_time += delta
	var t = interpolation_time / interpolation_duration
	if t >= 1.0:
		t = 1.0
		is_interpolating = false
	
	# Linearly interpolate between the current rotation and the target rotation
	rotation_degrees = lerp(rotation_degrees, target_rotation, t)
