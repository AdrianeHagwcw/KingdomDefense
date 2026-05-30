extends Node2D

signal reached_tower

func _on_area_2d_area_entered(area):
	if area.is_in_group("tower"):
		reached_tower.emit()
