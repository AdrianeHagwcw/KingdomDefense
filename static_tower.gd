extends StaticBody2D

signal tower_destroyed

@export var projectile_scene: PackedScene
@export var attack_range = 850.0
@export var attack_speed = 1.0
@export var projectile_damage = 5

var max_health = 100
var health = 100
var is_dead = false
var shooting = false
var current_target = null  # ✅ Remember current target

@onready var health_bar = get_node("../TowerHealthBar")
@onready var health_label = get_node("../TowerHealthLabel")

func _ready():
	print("Tower Ready")
	add_to_group("tower")
	update_health_ui()
	start_shooting()

func start_shooting():
	if shooting:
		return
	shooting = true
	print("Shooting system started")
	while shooting:
		await get_tree().create_timer(attack_speed).timeout
		if is_dead:
			continue
		var enemy = get_closest_enemy()
		if enemy != null:
			shoot(enemy)

func get_closest_enemy():
	# ✅ Keep attacking current target if it's still alive
	if current_target != null and is_instance_valid(current_target):
		var distance = global_position.distance_to(current_target.global_position)
		if distance < attack_range:
			return current_target  # Stick to current target
	
	# ✅ Only search for new target if current is dead
	var enemies = get_tree().get_nodes_in_group("enemy")
	var closest_enemy = null
	var closest_distance = attack_range
	
	for enemy in enemies:
		if !is_instance_valid(enemy):
			continue
		var distance = global_position.distance_to(enemy.global_position)
		if distance < closest_distance:
			closest_distance = distance
			closest_enemy = enemy
	
	if closest_enemy != null:
		current_target = closest_enemy  # ✅ Set new target
	
	return closest_enemy

func shoot(enemy):
	if projectile_scene == null:
		return
	var projectile = projectile_scene.instantiate()
	get_tree().current_scene.add_child(projectile)
	projectile.global_position = Vector2(578, 360)
	projectile.target = enemy
	projectile.damage = projectile_damage

func take_damage(amount):
	if is_dead:
		return
	health -= amount
	if health < 0:
		health = 0
	update_health_ui()
	if health <= 0:
		die()

func update_health_ui():
	health_bar.max_value = max_health
	health_bar.value = health
	health_label.text = "Tower HP: %d/%d" % [health, max_health]

func reset_tower():
	is_dead = false
	health = max_health
	show()
	update_health_ui()
	current_target = null  # ✅ Reset target on restart
	if not shooting:
		start_shooting()

func die():
	if is_dead:
		return
	is_dead = true
	shooting = false
	current_target = null  # ✅ Clear target
	print("Tower Destroyed!")
	tower_destroyed.emit()
