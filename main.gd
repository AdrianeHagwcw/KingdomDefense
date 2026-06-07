extends Node2D

@export var north_enemy: PackedScene
@export var west_enemy: PackedScene
@export var east_enemy: PackedScene
@export var south_enemy: PackedScene

@onready var north_path = $NorthPath
@onready var west_path = $WestPath
@onready var east_path = $EastPath
@onready var south_path = $SouthPath
@onready var main_menu = $CanvasLayer/MainMenu
@onready var timer_label = $CanvasLayer/Panel/TimerLabel
@onready var hud_panel = $CanvasLayer/Panel
@onready var tower_health_bar = $TowerHealthBar
@onready var tower_health_label = $TowerHealthLabel
@onready var tower = $StaticTower

# NEW: Gold and upgrade UI — add these 3 nodes inside CanvasLayer/Panel in the editor
@onready var gold_label = $CanvasLayer/Panel/GoldLabel
@onready var upgrade_button = $CanvasLayer/Panel/UpgradeButton
@onready var tower_level_label = $CanvasLayer/Panel/TowerLevelLabel

@onready var game_nodes: Array[Node] = [
	$MapBg, $StaticTower, $NorthPath, $WestPath, $EastPath, $SouthPath
]

var elapsed_time = 0.0
var timer_started = false
var game_started = false
var spawn_loops_started = false
var gold: int = 0                          # NEW

func _ready():
	main_menu.start_game_pressed.connect(start_game)
	main_menu.restart_game_pressed.connect(restart_game)
	tower.tower_destroyed.connect(_on_tower_destroyed)
	tower.tower_upgraded.connect(_on_tower_upgraded)
	if upgrade_button:
		upgrade_button.pressed.connect(_on_upgrade_button_pressed)  # NEW
	set_game_world_visible(false)
	set_hud_visible(false)
	elapsed_time = 0.0
	update_timer_label()
	main_menu.show_main_menu()

func _process(delta):
	if not game_started:
		return
	if timer_started:
		elapsed_time += delta
		update_timer_label()

func start_game():
	clear_enemies()
	elapsed_time = 0.0
	gold = 0                               # NEW: reset gold on new game
	update_timer_label()
	game_started = true
	timer_started = true
	set_game_world_visible(true)
	set_hud_visible(true)
	if tower.has_method("reset_tower"):
		tower.reset_tower()
	update_gold_ui()                       # NEW
	start_spawn_loops_once()

func restart_game():
	start_game()

func _on_tower_destroyed():
	game_started = false
	timer_started = false
	clear_enemies()
	set_hud_visible(false)
	set_game_world_visible(false)
	main_menu.show_game_over()

# ── Gold System ────────────────────────────────────────────────────────────────

func add_gold(amount: int):                # NEW: called by enemy died signal
	gold += amount
	update_gold_ui()

func update_gold_ui():
	gold_label.text = "Gold: %d" % gold
	update_upgrade_button()

func update_upgrade_button():
	var cost = tower.get_upgrade_cost()
	if cost == -1:
		upgrade_button.text = "MAX LEVEL"
		upgrade_button.disabled = true
		tower_level_label.text = "%s  [MAX]" % tower.get_level_name()
	else:
		upgrade_button.text = "Upgrade  (%d Gold)" % cost
		upgrade_button.disabled = false
		tower_level_label.text = "%s  [Lv %d]" % [tower.get_level_name(), tower.tower_level + 1]

func _on_upgrade_button_pressed():
	var cost = tower.get_upgrade_cost()
	if cost == -1 or gold < cost:
		return
	gold -= cost
	tower.upgrade()
	update_gold_ui()

func _on_tower_upgraded(_new_level: int):  # NEW: signal handler
	update_upgrade_button()

# ── Visibility ─────────────────────────────────────────────────────────────────

func set_game_world_visible(value: bool):
	for node in game_nodes:
		node.visible = value

func set_hud_visible(value: bool):
	hud_panel.visible = value
	tower_health_bar.visible = value
	tower_health_label.visible = value
	gold_label.visible = value             # NEW
	upgrade_button.visible = value         # NEW
	tower_level_label.visible = value      # NEW

# ── Timer ──────────────────────────────────────────────────────────────────────

func update_timer_label():
	var total_seconds = int(elapsed_time)
	var minutes = total_seconds / 60
	var seconds = total_seconds % 60
	timer_label.text = "Time - %02d:%02d" % [minutes, seconds]

# ── Spawning ───────────────────────────────────────────────────────────────────

func start_spawn_loops_once():
	if spawn_loops_started:
		return
	spawn_loops_started = true
	start_north()
	start_west()
	start_east()
	start_south()

func start_north():
	while true:
		await get_tree().create_timer(3.0).timeout
		if game_started and north_enemy != null:
			spawn_enemy(north_path, north_enemy)

func start_west():
	while true:
		await get_tree().create_timer(4.0).timeout
		if game_started and west_enemy != null:
			spawn_enemy(west_path, west_enemy)

func start_east():
	while true:
		await get_tree().create_timer(5.0).timeout
		if game_started and east_enemy != null:
			spawn_enemy(east_path, east_enemy)

func start_south():
	while true:
		await get_tree().create_timer(6.0).timeout
		if game_started and south_enemy != null:
			spawn_enemy(south_path, south_enemy)

func spawn_enemy(path: Path2D, enemy_scene: PackedScene):
	if not game_started or enemy_scene == null or path == null:
		return
	var path_follow = PathFollow2D.new()
	path_follow.loop = false
	path_follow.rotates = false
	path.add_child(path_follow)
	var enemy = enemy_scene.instantiate()
	path_follow.add_child(enemy)
	enemy.position = Vector2.ZERO
	# NEW: connect this enemy's death signal so dropping gold works
	enemy.died.connect(add_gold)

func clear_enemies():
	var paths = [north_path, west_path, east_path, south_path]
	for path in paths:
		if path == null:
			continue
		for child in path.get_children():
			if child is PathFollow2D:
				child.queue_free()
