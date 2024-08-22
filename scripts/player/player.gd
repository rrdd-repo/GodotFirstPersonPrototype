extends CharacterBody3D

@onready var camera: Camera3D = $CameraPivot/Camera
@onready var raycast: RayCast3D = $CameraPivot/Camera/RayCast3D
@onready var rotation_speed: float = 1.0

@export var move_speed: float = 5.0
@export var jump_velocity:float = 4.5
var teleport_points: Array = []
var current_index: int = 0
var moving: bool = false
var target_position: Vector3

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity:float = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready() -> void:
	raycast.enabled = true
	
func _input(event: InputEvent) -> void:
	# Debug Camera
	if event is InputEventMouseButton:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	elif event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta
	
	if moving:
		move_towards_target(delta)
		# Handle jump.
		if Input.is_action_just_pressed("jump") and is_on_floor():
			velocity.y = jump_velocity
			
	elif Input.is_action_just_pressed("move_up"):
		set_next_target()
	
	move_and_slide()

func set_next_target() -> void:
	# Update the raycast and check for collision
	raycast.force_raycast_update()
	
	if raycast.is_colliding():
		var collider = raycast.get_collider()
	
		if collider.is_in_group("teleport_points"):
			target_position = Vector3(collider.global_transform.origin.x, velocity.y, collider.global_transform.origin.z)
			moving = true
	else:
		print("No teleport point hit by raycast")

func move_towards_target(delta) -> void:
	var current_position = global_transform.origin
	var direction = (target_position - current_position).normalized()
	var distance_to_target = current_position.distance_to(target_position)

	if distance_to_target < move_speed * delta:
		# Close enough to target, snap to target and stop moving
		global_transform.origin = target_position
		moving = false
	else:
		# Move towards the target
		global_transform.origin += direction * move_speed * delta
