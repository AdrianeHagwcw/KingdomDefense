extends StaticBody2D

signal tower_destroyed
signal tower_upgraded(new_level: int)     # NEW

var current_target = null
var enemies_in_range = []

# Assign these 4 scenes in the Inspector (duplicate projectile scene, change sprite each time)
@export var projectile_scene_lv1: PackedScene   # Arrow
@export var projectile_scene_lv2: PackedScene   # Rock
@export var projectile_scene_lv3: PackedScene   # Spear
@export var projectile_scene_lv4: PackedScene   # Cannonball

@onready var wooden_tower = $Lvl1Tower
@onready var stone_tower = $Lvl2Tower
@onready var iron_tower = $Lvl3Tower
@onready var golden_tower = $Lvl4Tower

# Tower stats per level — index 0 = Level 1, index 3 = Level 4 (max)
const LEVEL_DATA = [
	{ "name": "Wooden Tower",  "damage": 30,  "attack_speed": 1.2, "range": 1500.0, "upgrade_cost": 500  },
	{ "name": "Stone Tower",   "damage": 50, "attack_speed": 0.8, "range": 1500.0, "upgrade_cost": 1500 },
	{ "name": "Iron Tower",    "damage": 70, "attack_speed": 0.6, "range": 1500.0, "upgrade_cost": 2300 },
	{ "name": "Cannon Tower",  "damage": 90, "attack_speed": 0.4, "range": 1500.0,"upgrade_cost": 0   },
]

var max_health = 100
var health = 100
var is_dead = false
var is_upgrading = false
var tower_level = 0                        # 0-based index into LEVEL_DATA
var shoot_version = 0                      # NEW: increment to cancel old shooting loops

@onready var health_bar = get_node("../TowerHealthBar")
@onready var health_label = get_node("../TowerHealthLabel")

func _ready():
	add_to_group("tower")
	update_health_ui()
	start_shooting()
	update_tower_appearance()

# ── Shooting ───────────────────────────────────────────────────────────────────

func start_shooting():
	shoot_version += 1

	var my_version = shoot_version

	while my_version == shoot_version:

		var spd = LEVEL_DATA[tower_level]["attack_speed"]

		await get_tree().create_timer(spd).timeout

		if my_version != shoot_version:
			return

		if is_dead or is_upgrading:
			continue

		var target = get_target()

		if target != null:
			shoot(target)
		
func get_target():

	if current_target != null:
		if is_instance_valid(current_target):
			return current_target

	current_target = null

	var best_enemy = null
	var highest_progress = -1.0

	var enemies = get_tree().get_nodes_in_group("enemy")

	for enemy in enemies:

		if !is_instance_valid(enemy):
			continue

		var distance = global_position.distance_to(
			enemy.global_position
		)

		if distance > LEVEL_DATA[tower_level]["range"]:
			continue

		var progress = enemy.get_parent().progress

		if progress > highest_progress:

			highest_progress = progress
			best_enemy = enemy

	current_target = best_enemy

	return best_enemy
	

func shoot_all_in_range():

	var current_range = LEVEL_DATA[tower_level]["range"]

	var north_target = null
	var south_target = null
	var east_target = null
	var west_target = null

	var north_progress = -1.0
	var south_progress = -1.0
	var east_progress = -1.0
	var west_progress = -1.0

	var enemies = get_tree().get_nodes_in_group("enemy")

	for enemy in enemies:

		if !is_instance_valid(enemy):
			continue

		var distance = global_position.distance_to(enemy.global_position)

		if distance > current_range:
			continue

		var path_follow = enemy.get_parent()

		if path_follow == null:
			continue

		var path_node = path_follow.get_parent()

		if path_node == null:
			continue

		var path_name = path_node.name
		var progress = path_follow.progress

		match path_name:

			"NorthPath":
				if progress > north_progress:
					north_progress = progress
					north_target = enemy

			"SouthPath":
				if progress > south_progress:
					south_progress = progress
					south_target = enemy

			"EastPath":
				if progress > east_progress:
					east_progress = progress
					east_target = enemy

			"WestPath":
				if progress > west_progress:
					west_progress = progress
					west_target = enemy

	# Fire one projectile per lane

	if north_target:
		shoot(north_target)

	if south_target:
		shoot(south_target)

	if east_target:
		shoot(east_target)

	if west_target:
		shoot(west_target)

func shoot(enemy):
	var scene = get_projectile_scene()
	if scene == null:
		return
	var projectile = scene.instantiate()
	get_tree().current_scene.add_child(projectile)
	projectile.global_position = $Lvl1Tower.global_position   # FIXED: was hardcoded Vector2(578,360)
	projectile.target = enemy
	projectile.damage = LEVEL_DATA[tower_level]["damage"]

func get_projectile_scene() -> PackedScene:
	match tower_level:
		0: return projectile_scene_lv1
		1: return projectile_scene_lv2
		2: return projectile_scene_lv3
		3: return projectile_scene_lv4
	return projectile_scene_lv1

# ── Upgrade ────────────────────────────────────────────────────────────────────

func upgrade():

	if tower_level >= LEVEL_DATA.size() - 1:
		return

	tower_level += 1

	update_tower_appearance()

	play_upgrade_animation()

	tower_upgraded.emit(tower_level)       # Notify main.gd

func play_upgrade_animation():
	is_upgrading = true
	if has_node("AnimatedSprite2D"):
		var sprite = $AnimatedSprite2D
		if sprite.sprite_frames != null and sprite.sprite_frames.has_animation("upgrade"):
			sprite.play("upgrade")
			await sprite.animation_finished
			if sprite.sprite_frames.has_animation("idle"):
				sprite.play("idle")
		else:
			# Fallback: yellow flash if no upgrade animation exists yet
			await _flash_yellow()
	else:
		await _flash_yellow()
	is_upgrading = false

func _flash_yellow():
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color(2.0, 2.0, 0.0, 1.0), 0.15)
	tween.tween_property(self, "modulate", Color(1.0, 1.0, 1.0, 1.0), 0.15)
	tween.tween_property(self, "modulate", Color(2.0, 2.0, 0.0, 1.0), 0.15)
	tween.tween_property(self, "modulate", Color(1.0, 1.0, 1.0, 1.0), 0.15)
	await tween.finished

func get_upgrade_cost() -> int:
	if tower_level >= LEVEL_DATA.size() - 1:
		return -1                           # -1 signals max level
	return LEVEL_DATA[tower_level]["upgrade_cost"]

func get_level_name() -> String:
	return LEVEL_DATA[tower_level]["name"]


func update_tower_appearance():

	wooden_tower.hide()
	stone_tower.hide()
	iron_tower.hide()
	golden_tower.hide()

	match tower_level:

		0:
			wooden_tower.show()

		1:
			stone_tower.show()

		2:
			iron_tower.show()

		3:
			golden_tower.show()

# ── Damage & Health ────────────────────────────────────────────────────────────

func take_damage(amount):
	if is_dead:
		return
	health -= amount
	health = max(health, 0)
	update_health_ui()
	if health <= 0:
		die()

func update_health_ui():
	health_bar.max_value = max_health
	health_bar.value = health
	health_label.text = "Tower HP: %d/%d" % [health, max_health]

func reset_tower():
	is_dead = false
	is_upgrading = false
	tower_level = 0
	health = max_health
	modulate = Color(1, 1, 1, 1)          # Reset any leftover flash color
	show()
	update_health_ui()
	start_shooting()                       # shoot_version increment inside handles old loops
	tower_level = 0
	update_tower_appearance()
	
func die():
	if is_dead:
		return
	is_dead = true
	shoot_version += 1                     # Stops the shooting loop
	print("Tower Destroyed!")
	tower_destroyed.emit()
