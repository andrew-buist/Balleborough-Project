extends WorldEnvironment

var libration = 10

var skyArray = [Color(0.78,0.94,0.94), Color(0.52,0.81,1.0), Color(0.92,0.41,0.41), Color(0.05,0.01,0.01)]
var horizonArray = [Color(0.65,0.65,0.67), Color(0.65,0.65,0.67), Color(0.80,0.10,0.69), Color(0.0,0.0,0.05)]
var groundArray = [Color(0.95,0.95,0.92), Color(0.95,0.95,0.92), Color(0.85,0.85,0.80), Color(0.20,0.10,0.20)]
var suncolArray = [Color(1.00,1.00,0.98), Color(1.00,1.00,0.94), Color(0.88,0.86,0.21), Color(0.10,0.10,0.20)]
var transitionArray = [1.00,1.00,0.20,5.00]
var sunbrightArray = [1.00,1.50,0.80,0]
var skyMaterial = self.environment.sky.get_material()

var time_now = 0.0
var time_of_day = 0.0

@onready var sun = $Sun

# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	
func alter_skybox(daytime, index_1, index_2, offset, period_length):
	var placeColor = (daytime - offset)/period_length
	
	sun.rotation.x = deg_to_rad(-daytime)
	
	skyMaterial.set_sky_top_color(skyArray[index_1].lerp(skyArray[index_2], placeColor ** transitionArray[index_1]))
	skyMaterial.set_sky_horizon_color(horizonArray[index_1].lerp(horizonArray[index_2], placeColor ** transitionArray[index_1]))
	skyMaterial.set_ground_horizon_color(horizonArray[index_1].lerp(horizonArray[index_2], placeColor ** transitionArray[index_1]))
	skyMaterial.set_ground_bottom_color(groundArray[index_1].lerp(groundArray[index_2], placeColor ** transitionArray[index_1]))
	sun.light_energy = sunbrightArray[index_1] + (sunbrightArray[index_2] - sunbrightArray[index_1]) * placeColor
	sun.set_color(suncolArray[index_1].lerp(suncolArray[index_2], placeColor))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	time_now = GlobalSignalBus.get("time_now")
	
	time_of_day = GlobalSignalBus.get("time_of_day")
	
	if time_of_day >= 0 and time_of_day <= 90:
		alter_skybox(time_of_day, 0, 1, 0, 90)
	if time_of_day > 90 and time_of_day <= 180:
		alter_skybox(time_of_day, 1, 2, 90, 90)
	if time_of_day > 180 and time_of_day <= 270:
		alter_skybox(time_of_day, 2, 3, 180, 90)
	if time_of_day > 270:
		alter_skybox(time_of_day, 3, 0, 270, 90)
		
