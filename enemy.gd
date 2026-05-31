extends Node2D

@export var speed: float = 50.0

var path_follow: PathFollow2D


func _ready():
	add_to_group("enemy")

	path_follow = get_parent() as PathFollow2D

	if has_node("AnimatedSprite2D"):
		$AnimatedSprite2D.play("walk")


func _process(delta):
	if path_follow:
		path_follow.progress += speed * delta


func _on_area_2d_area_entered(area: Area2D) -> void:
	var tower = null

	# Case 1: The Area2D itself is in the tower group.
	if area.is_in_group("tower"):
		tower = area

	# Case 2: The Area2D is a child of StaticTower.
	elif area.get_parent() != null and area.get_parent().is_in_group("tower"):
		tower = area.get_parent()

	if tower != null and tower.has_method("take_damage"):
		tower.take_damage(10)

		if path_follow != null:
			path_follow.queue_free()
		else:
			queue_free()
