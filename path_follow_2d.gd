extends PathFollow2D

@export var speed: float = 100.0
var stopped: bool = false
var active: bool = false

func _ready():
	$Enemy/AnimatedSprite2D.play("walk")

	if $Enemy.has_signal("reached_tower"):
		$Enemy.reached_tower.connect(_on_reached_tower)

func _process(delta):
	if active and !stopped:
		progress += speed * delta

func _on_reached_tower():
	stopped = true
