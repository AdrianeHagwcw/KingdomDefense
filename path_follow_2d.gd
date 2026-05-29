extends PathFollow2D

@export var speed = 100.0

func _ready():
	$Enemy/AnimatedSprite2D.play("walk")

func _process(delta):
	progress += speed * delta
