extends MeshInstance3D
var day_tick
var rand_light_ctrl
var rand_light_enabled

@export var tex_unlit: Array[Texture] = []
@export var tex_lit: Array[Texture] = []
@export var tex_emit: Array[Texture] = []
@export var override_slot: Array[int] = []
@export var emission_colour: Color
@export var emission_strength = 64

var mat_unlit: Array[Material] = []
var mat_lit: Array[Material] = []

# Called when the node enters the scene tree for the first time.
func _ready():
	#so first day gets initial tick
	day_tick = -1
	
	for i in range(0,override_slot.size()):
		var mat_unlit_temp = StandardMaterial3D.new()
		var mat_lit_temp = StandardMaterial3D.new()
		
		mat_unlit_temp.albedo_texture = tex_unlit[i]
		mat_lit_temp.albedo_texture = tex_lit[i]
		mat_lit_temp.emission_enabled = 1
		mat_lit_temp.emission = emission_colour
		mat_lit_temp.emission_texture = tex_emit[i]
		mat_lit_temp.emission_energy_multiplier = 1
		mat_lit_temp.emission_operator = 1
		
		mat_unlit.append(mat_unlit_temp)
		mat_lit.append(mat_lit_temp)
		
	##set child light settings
	#for light in self.get_children():
		#print(light)
		#light.light_color = emission_colour
		#light.omni_range = emission_strength

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta): 
	#if new day then make new lights-on delay
	if(day_tick < GlobalSignalBus.day_counter):
		#time at which to turn lights on
		rand_light_ctrl = [randi() % 60,randi() % 60]
		#random roll to control if lights come on at all
		#(stops all lights coming on for more variation)
		rand_light_enabled = randf()
	
	#tick up
	day_tick = GlobalSignalBus.day_counter
	
	if(GlobalSignalBus.get("time_of_day") <= (180 + rand_light_ctrl[0]) or
		GlobalSignalBus.get("time_of_day") >= (360 - rand_light_ctrl[1])):
		for slot in range(0,override_slot.size()):
			self.set_surface_override_material(override_slot[slot], mat_unlit[slot])
	elif rand_light_enabled > 0.3:
		for slot in range(0,override_slot.size()):
			self.set_surface_override_material(override_slot[slot], mat_lit[slot])
