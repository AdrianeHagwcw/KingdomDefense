extends Node2D

@onready var north_path = $NorthPath/PathFollow2D
@onready var west_path = $WestPath/PathFollow2D
@onready var east_path = $EastPath/PathFollow2D
@onready var south_path = $SouthPath/PathFollow2D

@onready var north_enemy = $NorthPath/PathFollow2D/Enemy
@onready var west_enemy = $WestPath/PathFollow2D/Enemy
@onready var east_enemy = $EastPath/PathFollow2D/Enemy
@onready var south_enemy = $SouthPath/PathFollow2D/Enemy

@onready var timer_label = $CanvasLayer/Panel/TimerLabel

var elapsed_time = 0.0
var timer_started = false

func _ready():
	north_enemy.hide()
	west_enemy.hide()
	east_enemy.hide()
	south_enemy.hide()

	timer_label.text = "Time - 00:00"

	start_wave()

func _process(delta):

	if timer_started:
		elapsed_time += delta

	var minutes = int(elapsed_time) / 60
	var seconds = int(elapsed_time) % 60

	timer_label.text = "Time - %02d:%02d" % [minutes, seconds]

func start_wave():

	await get_tree().create_timer(2.0).timeout

	# FIRST MONSTER SPAWNS
	north_enemy.show()
	north_path.active = true

	# START TIMER HERE
	timer_started = true

	await get_tree().create_timer(4.0).timeout

	west_enemy.show()
	west_path.active = true

	await get_tree().create_timer(6.0).timeout

	east_enemy.show()
	east_path.active = true

	await get_tree().create_timer(8.0).timeout

	south_enemy.show()
	south_path.active = true
