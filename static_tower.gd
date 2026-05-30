extends StaticBody2D

var health = 100

func _on_area_2d_body_entered(body):

	if body.is_in_group("enemy"):
		take_damage(10)

func take_damage(amount):

	health -= amount
	
	print("Tower HP: ", health)

	if health <= 0:
		die()

func die():

	print("Tower Destroyed!")
	queue_free()


func _on_area_2d_area_entered(area: Area2D) -> void:
	pass # Replace with function body.


func _on_enemy_reached_tower() -> void:
	pass # Replace with function body.
