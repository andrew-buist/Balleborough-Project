extends Control

func _on_city_pressed():
	get_tree().change_scene_to_file("res://scenes/1_maps/1_local/1_overworld/1_city_map.tscn")

func _on_debug_pressed():
	get_tree().change_scene_to_file("res://scenes/1_maps/1_local/0_misc/0_debug_map1.tscn")
