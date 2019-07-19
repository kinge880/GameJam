extends Node2D

func _ready():
	$AnimationPlayer.play("start")
	
func _on_Reset_pressed():
	get_tree().change_scene("res://Word.tscn")
