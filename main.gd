extends Node2D

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
