@tool
extends Node

##The StaticBody3D to use in player_manual_handling detection
@export var static_body: StaticBody3D
@export var target_scene: PackedScene

func _ready():
	BaseFunctions.add_door_to_scene(static_body, target_scene)
