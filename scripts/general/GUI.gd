extends ReferenceRect

@onready var day_label = $day_counter/hbox/pane/day_label
@onready var cursor = $Cursor

@onready var context1_popup = $context_popup1
@onready var context1_popup_label1 = $context_popup1/hbox/left_pane/text
@onready var context1_popup_label2 = $context_popup1/hbox/icon_pane/icon
@onready var context1_popup_label3 = $context_popup1/hbox/right_pane/text
@onready var context1_popup_anim = $context_popup1/AnimationPlayer

@onready var context2_popup = $context_popup2
@onready var context2_popup_label1 = $context_popup2/pane/hbox/left_pane/text
@onready var context2_popup_label3 = $context_popup2/pane/hbox/right_pane/text
@onready var context2_popup_anim = $context_popup2/AnimationPlayer

var item_count: Dictionary = {}

var cursor_style_dict = {
	"refresh": "default",
	"door_open": "door_open",
	"door_closed": "door_closed",
	"item_grab": "item_grab",
	"item_operate": "item_operate",
	"dialog": "dialog"
}

func item_popup(item):
	var count_str
	var count = item_count[item]
	
	context1_popup_label3.label_settings.font_color = Color(0.91807717084885, 0.5113428235054, 0.50761127471924)
	
	if item.icon:
		context1_popup_label2.texture = load(item.icon)
	
	#handle item multiples
	if count == 1:
		count_str = ""
	else:
		count_str = " (x" + str(count) + ")"
	
	#set text fields
	context1_popup_label1.text = "Got a"
	context1_popup_label3.text = item.name + count_str + "!"
	
func money_popup():
	context2_popup_label3.label_settings.font_color = Color(0.32771402597427, 0.74550545215607, 0.46558904647827)
	
	context2_popup_label3.text = str(GlobalSignalBus.player_wallet)
	
	if !context2_popup_anim.is_playing():
		context2_popup_anim.play("show")
	else:
		context2_popup_anim.seek(context2_popup_anim.current_animation_length/2)

# Called when the node enters the scene tree for the first time.
func _ready():
	GlobalSignalBus.connect("add_item",_on_item_add)
	GlobalSignalBus.connect("add_money",_on_money_add)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	day_label.text = "Day: " + str(GlobalSignalBus.day_counter)
	if(GlobalSignalBus.player_thought):
		cursor.play(cursor_style_dict[GlobalSignalBus.player_thought])
	else:
		cursor.play("default")

func _on_item_add(item):
	if !item in item_count.keys():
		item_count[item] = 1
		context1_popup_anim.queue("show")
	else:
		item_count[item] += 1
	
	if item == item_count.keys()[0]:
		item_popup(item_count.keys()[0])
		if item_count[item] > 1:
			context1_popup_anim.seek(context1_popup_anim.current_animation_length/2)
	
	print(item_count)

func _on_money_add(item):
	money_popup()

func _on_animation_player_animation_changed(old_name, new_name):
	item_count.erase(item_count.keys()[0])
	item_popup(item_count.keys()[0])

func _on_animation_player_animation_finished(anim_name):
	item_count = {}
