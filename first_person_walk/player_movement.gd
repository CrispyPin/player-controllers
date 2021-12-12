extends KinematicBody

export var speed_walk := 3.0
export var speed_run  := 6.0
export var jump_power := 5.0

export var accel_air := 0.05
export var accel_ground := 0.25
export var coyote_time := 0.1

export var sensitivity_h := 1.0
export var sensitivity_v := 1.0

export var gravity := -9.81

var is_grounded := false
var _time_since_grounded := 0.0

var _speed_target := 0.0 # run / walk speed, whatever is active
var _accel_current := 1.0 # air/ground acceleration, whatever is active
var _velocity := Vector3()


func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _input(event):
	if event is InputEventMouseMotion:
		var angle_x = -event.relative.y * sensitivity_v * 0.002
		angle_x = clamp(angle_x, -PI*0.5 - $Head.rotation.x, PI*0.5 - $Head.rotation.x)
		$Head.rotate_object_local(Vector3(1,0,0), angle_x)

		var angle_y = -event.relative.x * sensitivity_h * 0.002
		rotate_y(angle_y)


func _physics_process(delta: float) -> void:
	is_grounded = is_on_floor()
	_update_accel()
	_update_speed()
	_movement()

	_velocity.y += delta * gravity


	if Input.is_action_just_pressed("jump") and _time_since_grounded < coyote_time:
		_velocity.y = jump_power
		_time_since_grounded += coyote_time*2
		is_grounded = false

	if is_grounded:
		_velocity = move_and_slide_with_snap(_velocity, Vector3.DOWN, Vector3.UP)
	else:
		_velocity = move_and_slide(_velocity, Vector3.UP)

	if is_grounded:
		_time_since_grounded = 0
	else:
		_time_since_grounded += delta


func _movement():
	var real_speed := speed_walk
	var movement := Vector3()
	if Input.is_action_pressed("forward"):
		movement += Vector3.FORWARD
		real_speed = _speed_target
	if Input.is_action_pressed("back"):
		movement += Vector3.BACK
	if Input.is_action_pressed("right"):
		movement += Vector3.RIGHT
	if Input.is_action_pressed("left"):
		movement += Vector3.LEFT

	movement = movement.normalized()
	movement *= real_speed
	movement = transform.basis.xform(movement)

	_velocity.x += (movement.x - _velocity.x) * _accel_current
	_velocity.z += (movement.z - _velocity.z) * _accel_current


func _update_speed() -> void:
	if Input.is_action_pressed("run"):
		_speed_target = speed_run
	else:
		_speed_target = speed_walk


func _update_accel() -> void:
	if _time_since_grounded < coyote_time:
		_accel_current = accel_ground
	else:
		_accel_current = accel_air

