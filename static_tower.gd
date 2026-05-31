extends StaticBody2D

var max_health = 100
var health = 100

<<<<<<< HEAD
func _on_area_2d_body_entered(body):
	if body.is_in_group("enemy"):
		take_damage(10)

func take_damage(amount):
	health -= amount
=======
@onready var health_bar = get_node("../TowerHealthBar")
@onready var health_label = get_node("../TowerHealthLabel")

func _ready():
	update_health_ui()

# Detect enemy Area2D entering tower Area2D
func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.get_parent().is_in_group("enemy"):
		take_damage(10)

		# Remove enemy
		area.get_parent().queue_free()

func take_damage(amount):
	health -= amount

	if health < 0:
		health = 0

	update_health_ui()

>>>>>>> main
	print("Tower HP: ", health)
	if health <= 0:
		die()

<<<<<<< HEAD
=======
func update_health_ui():
	health_bar.max_value = max_health
	health_bar.value = health

	health_label.text = "Tower HP: %d/%d" % [health, max_health]

>>>>>>> main
func die():
	print("Tower Destroyed!")
	queue_free()
