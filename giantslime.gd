extends Node2D

@export var speed: float = 50.0
@export var max_health: int = 20
@export var gold_reward: int = 10          # NEW: gold given on death

signal died(gold_amount: int)              # NEW: main.gd listens to this

var health: int
var path_follow: PathFollow2D
var attacking = false
var is_dying = false                       # NEW: prevents double-death

func _ready():
	add_to_group("enemy")
	health = max_health
	path_follow = get_parent() as PathFollow2D
	if has_node("AnimatedSprite2D"):
		$AnimatedSprite2D.play("walk")

func _process(delta):
	if attacking or is_dying:              # NEW: stop movement when dying
		return
	if path_follow:
		path_follow.progress += speed * delta

func _on_area_2d_area_entered(area):

	if attacking or is_dying:
		return

	if area.name == "Hitbox":

		var tower = area.get_parent()

		if tower != null:

			attacking = true

			start_attacking(tower)

func start_attacking(tower):
	while attacking and !is_dying:
		# NEW: safety check — self might be freed after await resumes
		if !is_instance_valid(self) or is_queued_for_deletion():
			return
		if tower == null or !is_instance_valid(tower):
			attacking = false
			return
		if tower.has_method("take_damage"):
			tower.take_damage(5)
		await get_tree().create_timer(1.0).timeout

func take_damage(amount):
	if is_dying:                           # NEW: no damage after death triggered
		return
	health -= amount
	if health <= 0:
		die()

func die():
	if is_dying:                           # NEW: prevents double-call
		return
	is_dying = true
	attacking = false

	# NEW: reward gold before freeing
	died.emit(gold_reward)

	# NEW: play death animation if it exists
	if has_node("AnimatedSprite2D"):
		var sprite = $AnimatedSprite2D
		if sprite.sprite_frames != null and sprite.sprite_frames.has_animation("die"):
			sprite.play("die")
			await sprite.animation_finished

	if path_follow and is_instance_valid(path_follow):
		path_follow.queue_free()
	else:
		queue_free()
