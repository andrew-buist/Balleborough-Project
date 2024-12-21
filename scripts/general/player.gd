extends CharacterBody3D

var active_object = {}

#Player settings
var speed = 10.0
var OG_SPEED = speed
const RUN_SPEED = 20.0
const MAX_STEP_HEIGHT = 0.3
const JUMP_VELOCITY = 15.0
const FLY_VELOCITY = 10.0
var fly_true = false

var _snapped_to_stairs_last_frame := false
var _last_frame_was_on_floor = -INF

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

#Camera Settings
var _save_camera_pivot_position = null
var _heading = Vector3.FORWARD

func _ready():
	%body_handling_collider.collide_with_areas = true
	%body_handling_collider.collide_with_bodies = false
	GlobalSignalBus.player_obj = self

func _physics_process(delta):
	BaseFunctions.interactive_object_handler(%manual_handling_collider)
	
	if is_on_floor():
		_last_frame_was_on_floor = Engine.get_physics_frames()
	elif not fly_true:
		velocity.y -= gravity * delta

	# Handle Jump.
	if Input.is_action_just_pressed("ui_accept") and (is_on_floor() or _snapped_to_stairs_last_frame) and not fly_true:
		velocity.y = JUMP_VELOCITY
		
	if Input.is_action_just_pressed("ui_fly_toggle"):
		fly_true = not fly_true
		velocity.y = 0.0
	
	if fly_true:
		if Input.is_action_pressed("ui_accept"):
			velocity.y = FLY_VELOCITY
		else:
			velocity.y = 0.0
		
	if Input.is_action_pressed("ui_run_button"):
		speed = RUN_SPEED
	else:
		speed = OG_SPEED

	# input direction vector
	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	# perpendicular to camera view for heading
	if (Input.is_action_pressed("ui_left")
	or Input.is_action_pressed("ui_right")
	or Input.is_action_pressed("ui_up")
	or Input.is_action_just_pressed("ui_down")):
		_heading = Vector3(input_dir.x, 0, input_dir.y).rotated(Vector3.UP, %camera.rotation.y).normalized()
	
	if _heading != null:
		look_at(global_position + _heading)
	if input_dir:
		velocity.x = _heading.x * speed
		velocity.z = _heading.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)
	
	if not _snap_up_to_stairs_check(delta):
		move_and_slide()
		_snap_down_to_stairs_check()

func _process(delta):
	GlobalSignalBus.player_obj = self

func is_surface_too_steep(normal: Vector3) -> bool:
	return normal.angle_to(Vector3.UP) > floor_max_angle

func _run_body_test_motion(from: Transform3D, motion: Vector3, result = null) -> bool:
	if not result:
		result = PhysicsTestMotionResult3D.new()
	var params = PhysicsTestMotionParameters3D.new()
	params.from = from
	params.motion = motion
	return PhysicsServer3D.body_test_motion(self.get_rid(), params, result)

func _snap_down_to_stairs_check() -> void:
	var did_snap := false
	var floor_below: bool = %stairs_d.is_colliding() and not is_surface_too_steep(%stairs_d.get_collision_normal())
	var was_on_floor_last_frame = Engine.get_physics_frames() - _last_frame_was_on_floor == 1
	if not is_on_floor() and velocity.y <= 0 and (was_on_floor_last_frame or _snapped_to_stairs_last_frame) and floor_below:
		var body_test_result = PhysicsTestMotionResult3D.new()
		if _run_body_test_motion(self.global_transform, Vector3(0, -MAX_STEP_HEIGHT, 0), body_test_result):
			var translate_y = body_test_result.get_travel().y
			self.position.y += translate_y
			apply_floor_snap()
			did_snap = true
	_snapped_to_stairs_last_frame = did_snap

func _snap_up_to_stairs_check(delta) -> bool:
	if not is_on_floor() and not _snapped_to_stairs_last_frame: return false
	var expected_move_motion = self.velocity * Vector3(1,0,1) * delta
	var step_pos_with_clearance = self.global_transform.translated(expected_move_motion + Vector3(0, MAX_STEP_HEIGHT * 2, 0))
	var down_check_result = PhysicsTestMotionResult3D.new()
	if(_run_body_test_motion(step_pos_with_clearance, Vector3(0, -MAX_STEP_HEIGHT * 2, 0), down_check_result)
	and (down_check_result.get_collider().is_class("StaticBody3D") or down_check_result.get_collider().is_class("CSGShape3D"))):
		var step_height = ((step_pos_with_clearance.origin + down_check_result.get_travel()) - self.global_position).y
		if step_height > MAX_STEP_HEIGHT or step_height <=0.01 or (down_check_result.get_collision_point() - self.global_position).y > MAX_STEP_HEIGHT: return false
		%stairs_f.global_position = down_check_result.get_collision_point() + Vector3(0, MAX_STEP_HEIGHT, 0) + expected_move_motion.normalized() * 0.1
		%stairs_f.force_raycast_update()
		if %stairs_f.is_colliding() and not is_surface_too_steep(%stairs_f.get_collision_normal()):
			self.global_position = step_pos_with_clearance.origin + down_check_result.get_travel()
			apply_floor_snap()
			_snapped_to_stairs_last_frame = true
			return true
	return false
