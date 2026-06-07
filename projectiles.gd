extends Area2D

@export var speed = 800.0
var target = null
var damage = 50

func _process(delta):
	if target == null or !is_instance_valid(target):
		queue_free()
		return
	
	# Move directly toward target without physics
	var direction = (target.global_position - global_position).normalized()
	global_position += direction * speed * delta
	
	look_at(target.global_position)
	
	if global_position.distance_to(target.global_position) < 10:
		if target.has_method("take_damage"):
			target.take_damage(damage)
		queue_free()


func _on_area_entered(area: Area2D) -> void:
	pass # Replace with function body.
