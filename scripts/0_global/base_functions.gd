@tool
extends Node

func load_json(path: String):
	var file =  FileAccess.open(path, FileAccess.READ)
	var content = file.get_as_text()
	file.close()
	var parsed_json = JSON.parse_string(content)
	return parsed_json

func get_all_children(in_node,arr:=[]):
	arr.push_back(in_node)
	for child in in_node.get_children():
		arr = get_all_children(child,arr)
	return arr

func make_self_global_interactive(node, item):
	GlobalSignalBus.local_items[node] = item
	

func add_item(item):
	GlobalSignalBus.player_inventory.push_front(item)
	GlobalSignalBus.emit_signal("add_item", item)

func add_money(item):
	GlobalSignalBus.player_wallet += item.cost
	GlobalSignalBus.emit_signal("add_money", item)

func interactive_object_handler(manual_handling):
	var manual_handling_collision = manual_handling.collision_result.filter(func(x): return x.collider in GlobalSignalBus.local_items.keys())
	
	var active_object = {}
	
	if(manual_handling_collision.size() > 0):
		manual_handling_collision = manual_handling_collision[0].collider
		active_object = reactive_ray_handler(manual_handling_collision)
	else:
		GlobalSignalBus.player_thought = "refresh"
	
	if(active_object and Input.is_action_just_pressed("ui_action1")):
		if active_object.type == "item":
			add_item(active_object)
		if active_object.type == "money":
			add_money(active_object)
		
		#erase after interaction if impermanent
		if !active_object.permanent:
			GlobalSignalBus.local_items.erase(manual_handling_collision)
			manual_handling_collision.queue_free()

#handles the reactive ray intersection case
#accesses global interactive dictionary for fetches
func reactive_ray_handler(manual_handling_collision):
	#register thought to player
	if(manual_handling_collision in GlobalSignalBus.local_items.keys()):
		var active_object = GlobalSignalBus.local_items[manual_handling_collision]
		if active_object.type in ["item","money"]:
			GlobalSignalBus.player_thought = "item_grab"
			return active_object
	#remove thought from player
	else:
		GlobalSignalBus.player_thought = "refresh"
		return({})
