extends Node2D

@export var speed: float = 50.0

var path_follow: PathFollow2D

func _ready():

	# Get parent PathFollow2D
	path_follow = get_parent() as PathFollow2D

	# Start animation
	if has_node("AnimatedSprite2D"):
		$AnimatedSprite2D.play("walk")

func _process(delta):

	if path_follow:
		path_follow.progress += speed * delta

func _on_area_2d_area_entered(area):

	if area.is_in_group("tower"):

		var tower = get_tree().get_first_node_in_group("tower")

		if tower:
			tower.take_damage(10)

		queue_free()
