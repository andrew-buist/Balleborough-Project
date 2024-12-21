extends SubViewport

@onready var itemlist = $ItemList

# Called when the node enters the scene tree for the first time.
func _ready():
	GlobalSignalBus.connect("add_item",_on_item_add)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_item_add(item):
	var icon = load(item.icon)
	itemlist.add_item(item.name, icon)
