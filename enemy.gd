extends Node2D

@export var speed: float = 50.0
@export var max_health: int = 30

var health: int
var path_follow: PathFollow2D
var attacking = false

func _ready():
	add_to_group("enemy")
	health = max_health
	path_follow = get_parent() as PathFollow2D
	if has_node("AnimatedSprite2D"):
		$AnimatedSprite2D.play("walk")

func _process(delta):
	if attacking:
		return
	if path_follow:
		path_follow.progress += speed * delta

func _on_area_2d_area_entered(area: Area2D):
	if area.name == "Hitbox" and !attacking:
		var tower = area.get_parent()
		attacking = true
		start_attacking(tower)

func start_attacking(tower):
	while attacking:
		if tower == null or !is_instance_valid(tower):
			attacking = false
			return
		if tower.has_method("take_damage"):
			tower.take_damage(5)
		await get_tree().create_timer(1.0).timeout

func take_damage(amount):
	health -= amount
	print("Enemy HP:", health)
	if health <= 0:
		die()

func die():
	attacking = false
	if path_follow:
		path_follow.queue_free()
	else:
		queue_free()
