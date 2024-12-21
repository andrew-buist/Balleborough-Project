extends AnimationPlayer

var init_speed = self.speed_scale

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	var offset : float = randi_range(0, self.current_animation_length)
	self.advance(offset)
	self.speed_scale = randf_range(init_speed/2,init_speed)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
