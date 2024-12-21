extends Label

var lset = label_settings
var text_arr = []
@export var debug_input: String
@export var tick_speed = 0.15
@export var board_size = 16
var text_board = Array(".".repeat(16).split())
var font_size = lset.font_size
var letter = 0; var step = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	offset_top = (128 - lset.font_size) / 2 + 16

func ticker():
	text_arr = debug_input.split()
	if letter != text_arr.size():
		text_board.push_back(str(text_arr[letter]))
		text_board.pop_front()
		letter += 1
	else:
		letter = 0
	text = "".join(text_board)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	step = step + delta
	if(step > tick_speed):
		ticker()
		step = 0
