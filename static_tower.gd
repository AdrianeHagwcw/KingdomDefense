extends StaticBody2D

signal tower_destroyed

var max_health = 100
var health = 100
var is_dead = false

@onready var health_bar = get_node("../TowerHealthBar")
@onready var health_label = get_node("../TowerHealthLabel")


func _ready():
	add_to_group("tower")
	update_health_ui()


func take_damage(amount):
	if is_dead:
		return

	health -= amount

	if health < 0:
		health = 0

	update_health_ui()

	print("Tower HP: ", health)

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


func die():
	if is_dead:
		return

	is_dead = true
	print("Tower Destroyed!")
	tower_destroyed.emit()
