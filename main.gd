extends Node2D

<<<<<<< HEAD
@onready var ui = $UI
@onready var main_menu = $UI/MainMenu

@onready var game_nodes: Array[Node] = [
	$MapBg,
	$StaticTower,
	$NorthPath,
	$SouthPath,
	$EastPath,
	$WestPath
]


func _ready():
	# Hide game first
	set_game_visible(false)

	# Show UI menu
	ui.show()
	main_menu.show()

	# Connect start_game signal from MainMenu
	if not main_menu.start_game.is_connected(_on_start_game):
		main_menu.start_game.connect(_on_start_game)

	print("MainMenu signal connected.")


func _on_start_game():
	print("START GAME SIGNAL RECEIVED")

	# Hide whole UI CanvasLayer
	ui.hide()

	# Show map, tower, paths, enemies
	set_game_visible(true)

	# Start enemy movement
	start_enemies()

	print("Game started!")


func set_game_visible(value: bool):
	for node in game_nodes:
		if node is CanvasItem:
			node.visible = value

		# Show/hide children too
		for child in node.get_children():
			set_visible_recursive(child, value)


func set_visible_recursive(node: Node, value: bool):
	if node is CanvasItem:
		node.visible = value

	for child in node.get_children():
		set_visible_recursive(child, value)


func start_enemies():
	var paths = [
		$NorthPath,
		$SouthPath,
		$EastPath,
		$WestPath
	]

	for path in paths:
		for child in path.get_children():
			if child is PathFollow2D:
				if child.has_method("start_moving"):
					child.start_moving()
=======
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
>>>>>>> main
