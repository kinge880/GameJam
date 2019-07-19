extends Area2D


func _ready():
	pass
	
func _dimiss():
	queue_free()

func _on_bookArea_body_entered(body):
	_dimiss()
