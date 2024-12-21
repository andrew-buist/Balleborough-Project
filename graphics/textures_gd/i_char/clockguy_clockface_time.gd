extends SubViewport

@onready var clockhand1:Line2D = $clockhand1
@onready var clockhand2:Line2D = $clockhand2

#start the clock at 6am when T = 0.0
var time_offset = 90.0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var t = GlobalSignalBus.time_of_day + time_offset
	
	clockhand1.rotation = deg_to_rad((fmod(t, 15.0) * 24))
	clockhand2.rotation = deg_to_rad((fmod(t/15, 24.0) * 30))
