extends PathFollow2D

@export var speed = 100.0
var stopped = false

func _ready():
	$Enemy/AnimatedSprite2D.play("walk")
	$Enemy.reached_tower.connect(_on_reached_tower)

func _process(delta):
	if !stopped:
		progress += speed * delta

func _on_reached_tower():
	stopped = true


func _on_enemy_reached_tower() -> void:
	pass # Replace with function body.
