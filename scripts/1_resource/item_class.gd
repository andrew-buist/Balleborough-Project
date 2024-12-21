@tool
extends Resource
class_name Item

var item: String = "debug_cube"

func _get_property_list() -> Array:
	return [
		{
			"name": "item",
			"type": TYPE_STRING,
			"hint": PROPERTY_HINT_ENUM,
			"hint_string": ",".join(preload("res://data/0_general/items.json").data.keys())
		}
	]
