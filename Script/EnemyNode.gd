extends Node2D

func _on_Enemy_kill():
	queue_free()
