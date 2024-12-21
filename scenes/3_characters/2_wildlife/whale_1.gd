extends AnimationPlayer

var rand_v = 0.0

# Called when the node enters the scene tree for the first time.
func _ready():
	self.play("swim_1")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#if coming to the end of an animation loop
	if current_animation_position/current_animation_length > 0.95:
		#generate random value
		rand_v = randf()
		#if higher than threshold, toggle between feeding and swimming modes
		#useful: if there are birds nearby, lower threshold?
		if rand_v > 0.99:
			if self.current_animation == "swim_1":
				self.play("gape_open")
				self.queue("gape_swim")
			else:
				self.play("gape_open", -1, -1, true)
				self.queue("swim_1")
