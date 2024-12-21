extends CharacterBody3D

const local_radius = 16.0
const speed = 0.025
const timer1_framecap = [3.0,10.0]
const player_int_radius = 8.0

@onready var target_location = global_position
@onready var character_anim = $character_scene/AnimationPlayer
@onready var character_anim_tree_node = $character_scene/AnimationTree
@onready var character_anim_tree = $character_scene/AnimationTree.get("parameters/playback")
@onready var debug_ball = SphereMesh.new()

var timer1 = 0
var duration1 = 0
var skeleton_node: Skeleton3D
var bone_head: int

func _ready():
	skeleton_node = find_child("Skeleton3D")
	bone_head = skeleton_node.find_bone("head")

func face_target_query(target:Node3D):
	var self_xz = Vector2(global_position.x,global_position.z)
	var targ_xz = Vector2(target.global_position.x,target.global_position.z)
	return PI - abs(angle_difference(global_rotation.y, atan2(self_xz.x-targ_xz.x,self_xz.y-targ_xz.y)))

func bone_to_target_transform(skeleton:Skeleton3D, bone_id:int, target:Node3D, angle_lim:float, interact_radius:float):
	#same as clear_override but might permit tweening
	var cur_pose:Transform3D = skeleton.global_transform * skeleton.get_bone_global_pose_no_override(bone_id)
	if face_target_query(target) < angle_lim and global_position.distance_to(target.global_position) < interact_radius:
		#move to face target
		var pos_groundlocked = target.global_position
		pos_groundlocked.y = global_position.y
		return global_transform.affine_inverse() * cur_pose.looking_at(pos_groundlocked + (Vector3.UP * 1), Vector3.UP, true)
	else:
		#move to rest position
		return false

func face_player():
	var new_dir = bone_to_target_transform(skeleton_node, bone_head, GlobalSignalBus.player_obj, PI/3, player_int_radius)
	if new_dir:
		skeleton_node.set_bone_global_pose_override(bone_head, new_dir, 1.0, true)
	else:
		skeleton_node.clear_bones_global_pose_override()

func idle(delta, duration):
	character_anim_tree.travel("idle")
	if waiting_timer(duration):
			duration1 = Time.get_unix_time_from_system() + randf_range(timer1_framecap[0],timer1_framecap[1])
			target_location = get_new_target(local_radius)

func wander(delta, target_location):
	duration1 += delta
	character_anim_tree.travel("walk")
	if character_anim_tree.get_current_node() == "walk":
	#set anims
	#ignore time spent walking
		var dir = -(target_location - global_position).normalized()
		look_at(global_position + dir)
		global_position += global_basis.z * speed
		move_and_slide()

func waiting_timer(duration):
	if Time.get_unix_time_from_system() >= duration:
		return true

func show_target(location):
	#if any debug spheres exist, remove them
	for child in get_tree().root.get_children()[0].get_children():
		remove_child(child)
		child.queue_free()
	var sphere = SphereMesh.new()
	var node = MeshInstance3D.new()
	node.mesh = sphere
	node.position = location
	get_tree().root.get_children()[0].add_child(node)

func get_new_target(radius):
	var space_state = get_world_3d().direct_space_state
	var rand_ray_origin = global_position + Vector3(randf_range(-radius,radius),1.0,randf_range(-radius,radius))
	var ray = PhysicsRayQueryParameters3D.create(rand_ray_origin,rand_ray_origin+Vector3.DOWN*10.0)
	if space_state.intersect_ray(ray):
		if(space_state.intersect_ray(ray).collider is StaticBody3D):
			var t_location = space_state.intersect_ray(ray).position
			#show_target(t_location)
			var wall_check_ray = PhysicsRayQueryParameters3D.create(global_position+Vector3.UP, t_location)
			if not space_state.intersect_ray(wall_check_ray) or space_state.intersect_ray(wall_check_ray).normal.y == 1.0:
				return t_location

func _physics_process(delta):
	#if target location is not null
	if target_location:
	#if within distance of destination
		if (target_location - global_position).length() < 1.0:
			idle(delta, duration1)
		else:
			wander(delta, target_location)
	#otherwise idle, pick up a new location
	else:
		idle(delta, duration1)
		
	#face player if valid
	face_player()
