extends Camera3D

## Camera Controller - Android-friendly touch camera controls

@export var rotation_speed: float = 0.005
@export var zoom_speed: float = 0.1
@export var min_zoom: float = 2.0
@export var max_zoom: float = 15.0
@export var pan_speed: float = 0.01

var target: Node3D = null
var distance: float = 5.0
var rotation_x: float = 0.0
var rotation_y: float = 0.0
var is_touching: bool = false
var touch_start_position: Vector2 = Vector2.ZERO
var last_touch_position: Vector2 = Vector2.ZERO
var touch_count: int = 0
var pinch_start_distance: float = 0.0
var initial_zoom: float = 5.0
var active_touches: Dictionary = {}

func _ready() -> void:
	# Set initial camera position
	distance = initial_zoom
	_update_camera_position()

func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		_handle_touch(event)
	elif event is InputEventScreenDrag:
		_handle_drag(event)
	elif event is InputEventMouseButton:
		_handle_mouse_button(event)
	elif event is InputEventMouseMotion:
		_handle_mouse_motion(event)

func _handle_touch(event: InputEventScreenTouch) -> void:
	if event.pressed:
		active_touches[event.index] = event.position
		touch_count += 1
		if touch_count == 1:
			touch_start_position = event.position
			last_touch_position = event.position
			is_touching = true
		elif touch_count == 2:
			# Start pinch zoom
			var other_touch = _get_other_touch(event.index)
			if other_touch != Vector2.ZERO:
				pinch_start_distance = touch_start_position.distance_to(other_touch)
				initial_zoom = distance
	else:
		active_touches.erase(event.index)
		touch_count -= 1
		if touch_count == 0:
			is_touching = false
		elif touch_count == 1:
			# Reset for single touch
			for i in active_touches:
				if i != event.index:
					var touch_pos = active_touches[i]
					if touch_pos != Vector2.ZERO:
						touch_start_position = touch_pos
						last_touch_position = touch_pos
					break

func _handle_drag(event: InputEventScreenDrag) -> void:
	active_touches[event.index] = event.position
	if touch_count == 1 and is_touching:
		# Single finger: rotate camera
		var delta = event.position - last_touch_position
		rotation_y -= delta.x * rotation_speed
		rotation_x -= delta.y * rotation_speed
		rotation_x = clamp(rotation_x, -PI/2.5, PI/2.5)
		last_touch_position = event.position
		_update_camera_position()
	elif touch_count == 2:
		# Two fingers: pinch zoom
		var other_touch = _get_other_touch(event.index)
		if other_touch != Vector2.ZERO:
			var current_distance = event.position.distance_to(other_touch)
			if pinch_start_distance > 0:
				var zoom_factor = pinch_start_distance / current_distance
				distance = clamp(initial_zoom * zoom_factor, min_zoom, max_zoom)
				_update_camera_position()

func _handle_mouse_button(event: InputEventMouseButton) -> void:
	if event.button_index == MOUSE_BUTTON_WHEEL_UP:
		distance = clamp(distance - zoom_speed, min_zoom, max_zoom)
		_update_camera_position()
	elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
		distance = clamp(distance + zoom_speed, min_zoom, max_zoom)
		_update_camera_position()

func _handle_mouse_motion(event: InputEventMouseMotion) -> void:
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		rotation_y -= event.relative.x * rotation_speed
		rotation_x -= event.relative.y * rotation_speed
		rotation_x = clamp(rotation_x, -PI/2.5, PI/2.5)
		_update_camera_position()

func _get_other_touch(exclude_index: int) -> Vector2:
	for i in active_touches:
		if i != exclude_index:
			var pos = active_touches[i]
			if pos != Vector2.ZERO:
				return pos
	return Vector2.ZERO

func _update_camera_position() -> void:
	if target:
		var target_pos = target.global_position
		var offset = Vector3.ZERO
		offset.x = distance * cos(rotation_x) * sin(rotation_y)
		offset.y = distance * sin(rotation_x)
		offset.z = distance * cos(rotation_x) * cos(rotation_y)
		global_position = target_pos + offset
		look_at(target_pos, Vector3.UP)
	else:
		var offset = Vector3.ZERO
		offset.x = distance * cos(rotation_x) * sin(rotation_y)
		offset.y = distance * sin(rotation_x)
		offset.z = distance * cos(rotation_x) * cos(rotation_y)
		global_position = offset
		look_at(Vector3.ZERO, Vector3.UP)

func set_target(new_target: Node3D) -> void:
	target = new_target
	_update_camera_position()

func reset_camera() -> void:
	rotation_x = 0.0
	rotation_y = 0.0
	distance = initial_zoom
	_update_camera_position()
	Events.camera_reset.emit()
	Events.log_event("camera_reset")

func zoom_in() -> void:
	distance = clamp(distance - zoom_speed * 2, min_zoom, max_zoom)
	_update_camera_position()

func zoom_out() -> void:
	distance = clamp(distance + zoom_speed * 2, min_zoom, max_zoom)
	_update_camera_position()
