extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 4.5
const MOUSE_SENSITIVITY = 0.2

@export var TILT_LOWER_DEG_LIMIT = -90
@export var TILT_UPPER_DEG_LIMIT = 90
@export var CAMERA_CONTROLLER: Camera3D
@export var input_controller: InputController 
@onready var arm_animation_tree: AnimationTree = $Camera3D/arm.animation_tree

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _update_face_to(controller_moved_x: float):
	var new_rotation = rotation_degrees.y - controller_moved_x
	transform.basis = Basis(Vector3(0, 1, 0), deg_to_rad(new_rotation))

func _update_camera(controller_moved_y: float):
	var new_tilt = CAMERA_CONTROLLER.rotation_degrees.x - controller_moved_y
	new_tilt = clamp(new_tilt, TILT_LOWER_DEG_LIMIT, TILT_UPPER_DEG_LIMIT)

	CAMERA_CONTROLLER.transform.basis = Basis(Vector3(1, 0, 0), deg_to_rad(new_tilt))

func _update_arm_animation():
	arm_animation_tree.set("parameters/conditions/is_falling", false)
	arm_animation_tree.set("parameters/conditions/is_idle", false)
	arm_animation_tree.set("parameters/conditions/is_jumping", false)
	arm_animation_tree.set("parameters/conditions/is_walking", false)
	if is_on_floor():
		if velocity.length() > 0.1:
			arm_animation_tree.set("parameters/conditions/is_walking", true)
		else:
			arm_animation_tree.set("parameters/conditions/is_idle", true)
	else:
		if velocity.y > 0:
			arm_animation_tree.set("parameters/conditions/is_jumping", true)
		else:
			arm_animation_tree.set("parameters/conditions/is_falling", true)
	

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle Jump.
	if input_controller.is_jump_just_pressed() and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = input_controller.get_input_vector()
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	var viewport_moved_delta = input_controller.get_viewport_moved_delta()
	_update_camera(viewport_moved_delta.y)
	_update_face_to(viewport_moved_delta.x)
	#move_and_collide(velocity * delta)
	_update_arm_animation()
	move_and_slide()
