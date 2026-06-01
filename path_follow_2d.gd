extends Node2D

@export var speed: float = 100.0

func _ready():

	if has_node("AnimatedSprite2D"):
		$AnimatedSprite2D.play("walk")

func _process(delta):

	var parent = get_parent()

	if parent is PathFollow2D:
		parent.progress += speed * delta

func _on_area_2d_area_entered(area):

	print("Enemy touched:", area.name)

	if area.is_in_group("tower"):

		print("Reached tower!")

		var tower = get_tree().get_first_node_in_group("tower")

		if tower:
			tower.take_damage(10)

		queue_free()
