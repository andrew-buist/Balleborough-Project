@tool
extends Node

signal add_item
signal add_money

signal remove_item

var player_ray_result
var interactive_element
var player_thought = ""
var player_obj

var local_items: Dictionary = {}
var player_inventory: Array[Dictionary] = []
var player_wallet: int = 0
@onready var items: Dictionary = BaseFunctions.load_json("res://data/0_general/items.json")

#multiples of 6 minute blocks
var day_length = 3.0

var day_counter
var time_start
var time_now

var time_of_day

func _ready():
	time_start = Time.get_unix_time_from_system()

func _process(_delta):
	time_now = (Time.get_unix_time_from_system() - time_start) * (1/day_length)
	time_of_day = fmod(time_now, 360)
	day_counter = floorf(time_now/360)
