@tool
extends Node

@export var def := Item.new()

@onready var static_body = $StaticBody3D
@onready var scene = $StaticBody3D/scene

@onready var item = GlobalSignalBus.items[def.item]

func _ready():
	BaseFunctions.make_self_global_interactive(static_body, item)
	
	if def.item != "debug_cube":
		var loaded_scene = load(item.scene).instantiate()
		scene.hide()
		static_body.add_child(loaded_scene)
