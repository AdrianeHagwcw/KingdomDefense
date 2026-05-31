extends PathFollow2D

@export var speed := 100.0

var stopped := true


func _ready():
	set_process(false)
	visible = false

	var enemy = get_node_or_null("Enemy")
	if enemy and enemy.has_signal("reached_tower"):
		enemy.reached_tower.connect(_on_reached_tower)

	var sprite = get_node_or_null("Enemy/AnimatedSprite2D")
	if sprite:
		sprite.stop()


func start_moving():
	progress = 0.0
	stopped = false
	visible = true
	set_process(true)

	var sprite = get_node_or_null("Enemy/AnimatedSprite2D")
	if sprite:
		sprite.play("walk")


func _process(delta):
	if not stopped:
		progress += speed * delta


func _on_reached_tower():
	stopped = true
	set_process(false)

	var sprite = get_node_or_null("Enemy/AnimatedSprite2D")
	if sprite:
		sprite.stop()
