extends Camera3D

const CAMERA_ROTATE_SPEED = 0.01
const MIN_ORBIT_DISTANCE = 3.0
const MAX_ORBIT_DISTANCE = 5.0
const CAMERA_MOVE_SPEED = 10.0
var distance = 5
var _new_position = null
var lspeed = 0.2

var _h_rot = 0.0  # Azimuth (horizontal rotation)
var _v_rot = 0.0    # Elevation (vertical rotation)


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _wall_clip_check():
	var _raycst_result = %camera_raycast.get_collision_point()
	if %camera_raycast.is_colliding() and _raycst_result.distance_to(%camera_orbit.global_position) > MIN_ORBIT_DISTANCE and _raycst_result.distance_to(%camera_orbit.global_position) < MAX_ORBIT_DISTANCE:
		return %camera_raycast.get_collision_point()
	return null

func _move_to_snap_point(delta):
	if _new_position == null:
		_new_position = %camera_snap.global_position
	elif %camera_root.global_position.distance_to(_new_position) > 0.01:
		%camera_root.global_position = %camera_root.global_position.lerp(_new_position,  max(CAMERA_MOVE_SPEED, %player_model_pivot.speed) * delta)
	else:
		_new_position = null

func _pivot_follow_player(delta):
	var cam_orbit_dist = %camera_root.global_position.distance_to(%camera_orbit.global_position)
	var cam_orbit_heading = %camera_root.global_position.direction_to(%camera_orbit.global_position).normalized() * Vector3(1,0,1)
	if cam_orbit_heading.length() < 0.1:
		("snapping")
		_move_to_snap_point(delta)
	if _new_position == null and cam_orbit_dist > MAX_ORBIT_DISTANCE:
		%camera_root.global_position = %camera_root.global_position.move_toward(%camera_orbit.global_position + cam_orbit_heading * MAX_ORBIT_DISTANCE,  max(CAMERA_MOVE_SPEED, %player_model_pivot.velocity.length()) * delta)
	if _new_position == null and cam_orbit_dist < MIN_ORBIT_DISTANCE:
		%camera_root.global_position = %camera_root.global_position.move_toward(%camera_orbit.global_position - cam_orbit_heading * MIN_ORBIT_DISTANCE,  max(CAMERA_MOVE_SPEED, %player_model_pivot.velocity.length()) * delta)
	look_at_from_position(%camera.global_position, %camera_orbit.global_position)

func _physics_process(delta):
	if Input.is_action_just_pressed("ui_focus_next") or _new_position != null:
		_move_to_snap_point(delta)
	_pivot_follow_player(delta)
	#_wall_clip_check()

func _input(event):
	if Input.is_key_pressed(KEY_ESCAPE):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	#if in "playing" context
	if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		if event is InputEventMouseMotion:
			#this is a sneaky way to interrupt the view snapping
			_new_position = null
			#get direction offset vector
			var _t_vector: Vector3 = %camera_root.global_position - %camera_orbit.global_position
			
			_t_vector = _t_vector.rotated(Vector3.DOWN, event.relative.x * CAMERA_ROTATE_SPEED)
			_t_vector = _t_vector.rotated(_t_vector.cross(Vector3.DOWN).normalized(), event.relative.y * CAMERA_ROTATE_SPEED)
			
			#_t_vector = _t_vector.rotated(_t_vector.cross(Vector3.DOWN).normalized(), event.relative.y * CAMERA_ROTATE_SPEED)
			#new offset pos
			%camera_root.global_position = %camera_orbit.global_position + _t_vector
