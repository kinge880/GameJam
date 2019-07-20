extends Area2D


func _ready():
	pass
	$AnimationPlayer.play("bounce")
	
func _dimiss():
	queue_free()

func _on_bookArea_body_entered(body):
	_dimiss()

func _on_bookLife_body_entered(body):
	_dimiss()

func _on_bookJarin_body_entered(body):
	_dimiss()

func _on_bookIgnis_body_entered(body):
	_dimiss()

func _on_bookEnergy_body_entered(body):
	_dimiss()
