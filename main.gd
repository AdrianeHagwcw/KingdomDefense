extends Node2D

@export var north_enemy: PackedScene
@export var west_enemy: PackedScene
@export var east_enemy: PackedScene
@export var south_enemy: PackedScene

@onready var north_path = $NorthPath
@onready var west_path = $WestPath
@onready var east_path = $EastPath
@onready var south_path = $SouthPath

@onready var timer_label = $CanvasLayer/Panel/TimerLabel

var elapsed_time = 0.0
var timer_started = true

func _ready():
	start_north()
	start_west()
	start_east()
	start_south()

func _process(delta):
	if timer_started:
		elapsed_time += delta

	var minutes = int(elapsed_time) / 60
	var seconds = int(elapsed_time) % 60

	timer_label.text = "Time - %02d:%02d" % [minutes, seconds]

# North lane spawns goblins
func start_north():
	while true:
		await get_tree().create_timer(3.0).timeout
		spawn_enemy(north_path, north_enemy)

# West lane spawns enemies
func start_west():
	while true:
		await get_tree().create_timer(4.0).timeout
		spawn_enemy(west_path, west_enemy)

# East lane spawns enemies
func start_east():
	while true:
		await get_tree().create_timer(5.0).timeout
		spawn_enemy(east_path, east_enemy)

# South lane spawns enemies
func start_south():
	while true:
		await get_tree().create_timer(6.0).timeout
		spawn_enemy(south_path, south_enemy)

# Spawns an enemy on a path
func spawn_enemy(path: Path2D, enemy_scene: PackedScene):
	if enemy_scene == null:
		return

	if path == null:
		return

	var path_follow = PathFollow2D.new()
	path_follow.loop = false
	path_follow.rotates = false

	path.add_child(path_follow)

	var enemy = enemy_scene.instantiate()
	path_follow.add_child(enemy)

	enemy.position = Vector2.ZERO
