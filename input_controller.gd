extends Node
class_name InputController

const MOUSE_SENSITIVITY = 0.2

# Called when the node enters the scene tree for the first time.
func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

var viewport_moved_delta = Vector2.ZERO

func _unhandled_input(event):
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		var motion = event as InputEventMouseMotion
		viewport_moved_delta += motion.relative * MOUSE_SENSITIVITY


func get_input_vector() -> Vector2:
	return Input.get_vector("left", "right", "up", "down")

func is_jump_just_pressed() -> bool:
	return Input.is_action_just_pressed("jump")

func is_pressed_attack() -> bool:
	return Input.is_action_pressed("attack")

func get_viewport_moved_delta() -> Vector2:
	# return moved delta after prev call
	var delta = viewport_moved_delta
	viewport_moved_delta = Vector2.ZERO
	return delta
