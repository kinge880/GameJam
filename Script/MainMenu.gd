extends Node2D

func _ready():
	$AnimationPlayer.play("entry")

func _on_NewGame_pressed():
	get_tree().change_scene("res://Word.tscn")


func _on_Exit_pressed():
	get_tree().quit()
